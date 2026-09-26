{ me, ... }:

let
  port = 8080;
in
{
  services.open-webui = {
    enable = true;
    inherit port;
    host = "0.0.0.0";
    environment = {
      OLLAMA_BASE_URL = "http://stockholm.${me.domains.mesh}:11434";
      SCARF_NO_ANALYTICS = "True";
      DO_NOT_TRACK = "True";
      ANONYMIZED_TELEMETRY = "False";
    };
  };

  nixdiag.units.open-webui.ports = [ port ];

  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ port ];
}
