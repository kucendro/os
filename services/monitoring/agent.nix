{ config, ... }:

{
  services.beszel.agent = {
    enable = true;
    openFirewall = false;
    environmentFile = config.sops.templates."beszel-agent-env".path;
  };

  nixdiag.units.beszel-agent.connections = [
    {
      to = "edge/beszel";
      label = "metrics";
    }
  ];

  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ 45876 ];
}
