{ config, ... }:

{
  #: unit prometheus-node-exporter
  #: -> nas/prometheus metrics
  services.prometheus.exporters.node = {
    enable = true;
    openFirewall = false;
    enabledCollectors = [ "systemd" ];
  };

  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [
    config.services.prometheus.exporters.node.port
  ];
}
