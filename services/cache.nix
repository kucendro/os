{ config, ... }:

let
  port = 5008;
in
{
  services.harmonia.cache = {
    enable = true;
    signKeyPaths = [ config.sops.secrets.harmonia-signing-key.path ];
    settings = {
      bind = "[::]:${toString port}";
      priority = 30;
    };
  };

  nixdiag.units.harmonia.expose = [
    {
      inherit port;
      scope = "mesh";
    }
  ];

  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ port ];
}
