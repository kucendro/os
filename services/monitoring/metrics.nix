{ config, ... }:

{
  services.prometheus.exporters.node = {
    enable = true;
    port = 9101;
    openFirewall = false;
    enabledCollectors = [ "systemd" ];
  };

  nixdiag.units.prometheus-node-exporter.connections = [
    {
      to = "nas/prometheus";
      label = "metrics";
    }
  ];

  mesh.ports.node-exporter = config.services.prometheus.exporters.node.port;
}
