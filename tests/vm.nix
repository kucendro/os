{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  real = inputs.self.nixosConfigurations.${config.networking.hostName}.config;
  secrets = import ./secrets.nix {
    inherit pkgs lib;
    inherit (real.sops) secrets;
  };
  binds = lib.filterAttrs (_: fs: lib.elem "bind" fs.options) real.fileSystems;
  socket = expose: "${if expose.udp then "udp" else "tcp"}/${toString expose.port}";
in
{
  options.vm = {
    skip = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };
    ports = lib.mkOption {
      type = lib.types.attrsOf (lib.types.listOf lib.types.str);
      default = { };
    };
  };

  config = {
    vm.skip =
      lib.attrNames config.virtualisation.oci-containers.containers
      ++ lib.optional (config.security.acme.certs != { }) "acme-order-renew";

    vm.ports = lib.mkMerge [
      (lib.mapAttrs (_: port: [ "tcp/${toString port}" ]) config.mesh.ports)
      (lib.mapAttrs (
        _: unit: map (port: "tcp/${toString port}") unit.ports ++ map socket unit.expose
      ) config.nixdiag.units)
    ];

    virtualisation = {
      memorySize = lib.mkDefault 4096;
      cores = 4;
      diskSize = 8192;
      fileSystems = lib.mapAttrs (_: fs: { inherit (fs) device fsType options; }) binds;
    };

    sops = {
      validateSopsFiles = false;
      age.keyFile = lib.mkForce "/run/vm-sops/key.txt";
      age.sshKeyPaths = lib.mkForce [ ];
      gnupg.sshKeyPaths = lib.mkForce [ ];
      secrets = lib.mapAttrs (_: secret: {
        sopsFile = lib.mkForce "${secrets}/${secret.format}";
      }) real.sops.secrets;
    };

    system.activationScripts = {
      vm-sops-key = lib.stringAfter [ "specialfs" ] ''
        install -D -m 400 ${secrets}/key.txt /run/vm-sops/key.txt
      '';
      vm-bind-sources = lib.concatMapStrings (fs: "mkdir -p ${fs.device}\n") (lib.attrValues binds);
      setupSecretsForUsers.deps = [ "vm-sops-key" ];
      setupSecrets.deps = [ "vm-sops-key" ];
    };

    systemd.services."serial-getty@ttyS0".enable = lib.mkForce false;

    services.tailscale.authKeyFile = lib.mkForce null;

    services.nixdiag.serve.docs = lib.mkIf config.services.nixdiag.serve.enable (
      lib.mkForce (pkgs.writeTextDir "${config.services.nixdiag.serve.subpath}/index.html" "vm")
    );
  };
}
