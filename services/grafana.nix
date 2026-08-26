{ config, me, ... }:

let
  port = 3000;
in
{
  #: monitor
  #: -> nas/prometheus metrics
  services.grafana = {
    enable = true;
    settings = {
      server = {
        http_addr = "0.0.0.0";
        http_port = port;
        domain = "grafana.${me.domains.home}";
        root_url = "https://grafana.${me.domains.home}";
      };
      security.secret_key = "$__file{${config.sops.secrets.grafana-secret-key.path}}";
    };
  };

  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ port ];
}
