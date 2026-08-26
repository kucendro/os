{ config, ... }:

{
  #: unit beszel-agent
  #: -> edge/beszel metrics
  services.beszel.agent = {
    enable = true;
    openFirewall = false;
    environmentFile = config.sops.templates."beszel-agent-env".path;
  };

  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ 45876 ];
}
