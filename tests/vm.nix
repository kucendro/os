{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  real = inputs.self.nixosConfigurations.${config.networking.hostName}.config;
  binds = lib.filterAttrs (_: fs: lib.elem "bind" fs.options) real.fileSystems;
  socket = expose: "${if expose.udp then "udp" else "tcp"}/${toString expose.port}";

  pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ2emJ0xYTyw8Su01xsxl/lPvRqqvHvCFQMAxeak5com vm";
  fake = name: if lib.hasSuffix "pubkey" name then pubkey else "vm";
  install =
    file: content:
    let
      owner = if file.owner != null then file.owner else toString file.uid;
      group = if file.group != null then file.group else toString file.gid;
      source = pkgs.writeText "vm-${lib.strings.sanitizeDerivationName file.name}" content;
    in
    "install -D -m ${file.mode} -o ${owner} -g ${group} ${source} ${file.path}\n";
  secrets = lib.attrValues config.sops.secrets;
  forUsers = lib.filter (secret: secret.neededForUsers) secrets;
  regular = lib.filter (secret: !secret.neededForUsers) secrets;
  render =
    template:
    builtins.replaceStrings (lib.attrValues config.sops.placeholder) (map fake (
      lib.attrNames config.sops.placeholder
    )) template.content;
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

    system.activationScripts = {
      setupSecretsForUsers = lib.mkForce (
        lib.stringAfter [ "specialfs" ] (
          lib.concatMapStrings (secret: install secret (fake secret.name)) forUsers
        )
      );
      setupSecrets = lib.mkForce (
        lib.stringAfter
          [
            "specialfs"
            "users"
            "groups"
          ]
          (
            lib.concatMapStrings (secret: install secret (fake secret.name)) regular
            + lib.concatMapStrings (template: install template (render template)) (
              lib.attrValues config.sops.templates
            )
          )
      );
      vm-bind-sources = lib.concatMapStrings (fs: "mkdir -p ${fs.device}\n") (lib.attrValues binds);
    };

    systemd.services."serial-getty@ttyS0".enable = lib.mkForce false;

    services.tailscale.authKeyFile = lib.mkForce null;

    services.nixdiag.serve.docs = lib.mkIf config.services.nixdiag.serve.enable (
      lib.mkForce (pkgs.writeTextDir "${config.services.nixdiag.serve.subpath}/index.html" "vm")
    );
  };
}
