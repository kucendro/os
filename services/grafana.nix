{ ... }:

let
  port = 3000;
in
{
  services.grafana = {
    enable = true;
    settings = {
      server = {
        http_addr = "0.0.0.0";
        http_port = port;
        domain = "grafana.home.kucendro.dev";
        root_url = "https://grafana.home.kucendro.dev";
      };
      security.secret_key = "HDXUVSOyLOdXHkz7CxXZYlMonEUgqJJPlOn4kOjI7KjpuYen";
    };
  };

  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ port ];
}
