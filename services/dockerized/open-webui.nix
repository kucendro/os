{ ... }:

let
  webPort = 8080;
  ollamaUrl = "http://workstation.ts.kucendro.dev:11434";
in
{
  virtualisation.oci-containers = {
    backend = "docker";

    containers.open-webui = {
      image = "ghcr.io/open-webui/open-webui:latest";
      volumes = [ "/var/lib/open-webui:/app/backend/data" ];

      environment = {
        TZ = "Europe/Prague";
        OLLAMA_BASE_URL = ollamaUrl;
        PORT = toString webPort;
      };

      extraOptions = [ "--network=host" ];
    };
  };

  systemd.services.docker-open-webui.unitConfig.RequiresMountsFor = [ "/mnt/data" ];

  systemd.tmpfiles.rules = [
    "d /var/lib/open-webui 0755 root root -"
  ];

  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ webPort ];
}
