{
  lib,
  pkgs,
  me,
  hostNames,
  ...
}:

let
  peer = import ../hosts/mobile/peer.nix;

  orderedHosts =
    (builtins.filter (h: builtins.elem h hostNames) peer.order)
    ++ (lib.subtractLists peer.order hostNames);

  sshConfig = ''
    Host ${lib.concatStringsSep " " orderedHosts}
      User ${me.name}
      IdentityFile ~/.ssh/id_ed25519
      ProxyCommand /opt/bin/tailscale --socket=/opt/var/run/tailscale/tailscaled.sock nc %h %p
  '';

  remarkableSetup = pkgs.writeShellApplication {
    name = "remarkable";
    runtimeInputs = with pkgs; [
      coreutils
      openssh
    ];
    text = ''
      export CLOUD_URL=https://remarkable.home.kucendro.dev
      export LOGIN_SERVER=https://edge.kucendro.dev
      export SSH_CONFIG=${lib.escapeShellArg sshConfig}
      export REACHES=${lib.escapeShellArg (lib.concatStringsSep " " orderedHosts)}
      export DEFAULT_REMOTE=${peer.defaultRemote}
    ''
    + builtins.readFile ../automations/remarkable-setup.sh;
  };
in
{
  environment.systemPackages = [ remarkableSetup ];
}
