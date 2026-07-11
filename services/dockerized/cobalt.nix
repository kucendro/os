{ ... }:

let
  apiPort = 9000;
  webPort = 8787;
  apiDomain = "cobaltapi.home.kucendro.dev";
  webDomain = "cobalt.home.kucendro.dev";
  apiUrl = "https://${apiDomain}/";
in
{
  virtualisation.oci-containers = {
    backend = "docker";

    containers.cobalt = {
      image = "ghcr.io/imputnet/cobalt:11";

      environment = {
        API_URL = apiUrl;
        API_PORT = toString apiPort;
      };

      extraOptions = [
        "--network=host"
        "--init"
        "--read-only"
      ];
    };

    containers.cobalt-web = {
      image = "ghcr.io/spotdemo4/cobalt-web:latest";

      environment = {
        WEB_DEFAULT_API = apiUrl;
        WEB_HOST = webDomain;
        PORT = toString webPort;
      };

      extraOptions = [ "--network=host" ];
    };
  };

  systemd.services.docker-cobalt.unitConfig.RequiresMountsFor = [ "/mnt/data" ];
  systemd.services.docker-cobalt-web.unitConfig.RequiresMountsFor = [ "/mnt/data" ];

  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [
    apiPort
    webPort
  ];
}
