{
  config,
  lib,
  inputs,
  me,
  ...
}:

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
  };

  sops.templates.allowed-signers = {
    content =
      lib.concatMapStrings
        (device: "${me.emails.personal} ${config.sops.placeholder."${device}-pubkey"}\n")
        [
          "nixbook"
          "mac"
        ];
    mode = "0444";
  };

  nixdiag.units.comin = { };

  mesh.ports.comin = config.services.comin.exporter.port;
}
