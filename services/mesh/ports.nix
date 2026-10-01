{ config, lib, ... }:

let
  cfg = config.mesh;
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

  config.networking.firewall.interfaces.${cfg.interface} = {
    allowedTCPPorts = lib.attrValues cfg.ports;
    allowedUDPPorts = cfg.udp;
  };
}
