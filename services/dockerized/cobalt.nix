{ ... }:

let
  webPort = 9000;
  apiUrl = "https://cobalt.home.kucendro.dev/";
in
{
  virtualisation.oci-containers = {
    backend = "docker";

    containers.cobalt = {
      image = "ghcr.io/imputnet/cobalt:11";

      environment = {
        API_URL = apiUrl;
        API_PORT = toString webPort;
      };

      extraOptions = [
        "--network=host"
        "--init"
        "--read-only"
      ];
    };
  };

  systemd.services.docker-cobalt.unitConfig.RequiresMountsFor = [ "/mnt/data" ];

  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ webPort ];
}
