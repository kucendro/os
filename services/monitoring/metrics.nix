{ config, ... }:

{
  services.prometheus.exporters.node = {
    enable = true;
    port = 9101;
    openFirewall = false;
    enabledCollectors = [ "systemd" ];
  };

  nixdiag.units.prometheus-node-exporter = { };

  mesh.ports.node-exporter = config.services.prometheus.exporters.node.port;
}
