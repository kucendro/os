{ config, ... }:

{
  services.prometheus.exporters.node = {
    enable = true;
    openFirewall = false;
    enabledCollectors = [ "systemd" ];
  };

  nixdiag.units.prometheus-node-exporter.connections = [
    {
      to = "nas/prometheus";
      label = "metrics";
    }
  ];

  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [
    config.services.prometheus.exporters.node.port
  ];
}
