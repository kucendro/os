{
  config,
  inputs,
  lib,
  me,
  pkgs,
  ...
}:

let
  notify = pkgs.writeShellApplication {
    name = "comin-telegram";
    runtimeInputs = [
      pkgs.coreutils
      inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.tg
    ];
    text = ''
      icon=✅🤤
      [ "$COMIN_STATUS" = "done" ] || icon=🥀
      text="$icon $COMIN_HOSTNAME ''${COMIN_GIT_SHA:0:7} $(head -n1 <<<"$COMIN_GIT_MSG")"
      [ -z "$COMIN_ERROR_MSG" ] || text="$text
      ''${COMIN_ERROR_MSG:0:3500}"
      BOT_TOKEN=$(<${config.sops.secrets.grafana-telegram-bottoken.path}) \
        CHAT_ID=${toString me.telegram.chatId} \
        timeout 30 tg silent "$text"
    '';
  };
in
{
  imports = [ inputs.comin.nixosModules.comin ];

  services.comin = {
    enable = true;
    remotes = [
      {
        name = "origin";
        url = "http://nas.${me.domains.mesh}:${toString config.nodes.nas.mesh.ports.gitea}/${me.name}/os.git";
        branches.main.name = "deploy";
      }
    ];
    sshAllowedSignersPath = config.sops.templates.allowed-signers.path;
    postDeploymentCommand = lib.getExe notify;
  };

  nixdiag.units.comin = { };

  mesh.ports.comin = config.services.comin.exporter.port;
}
