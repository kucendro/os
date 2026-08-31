{ config, ... }:

let
  port = 5008;
in
{
  #: expose 5008 mesh
  services.harmonia.cache = {
    enable = true;
    signKeyPaths = [ config.sops.secrets.harmonia-signing-key.path ];
    settings = {
      bind = "[::]:${toString port}";
      priority = 30;
    };
  };

  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ port ];
}
