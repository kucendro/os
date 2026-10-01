{ config, lib, ... }:

let
  cfg = config.mesh;
  taken = lib.attrValues cfg.ports;
  clashes = lib.filterAttrs (_: port: lib.count (p: p == port) taken > 1) cfg.ports;
in
{
  options.mesh = {
    interface = lib.mkOption {
      type = lib.types.str;
      default = config.services.tailscale.interfaceName;
    };
    ports = lib.mkOption {
      type = lib.types.attrsOf lib.types.port;
      default = { };
    };
    udp = lib.mkOption {
      type = lib.types.listOf lib.types.port;
      default = [ ];
    };
  };

  config = {
    assertions = [
      {
        assertion = clashes == { };
        message = "mesh.ports clash: ${
          lib.concatStringsSep ", " (lib.mapAttrsToList (name: port: "${name}=${toString port}") clashes)
        }";
      }
    ];

    networking.firewall.interfaces.${cfg.interface} = {
      allowedTCPPorts = taken;
      allowedUDPPorts = cfg.udp;
    };
  };
}
