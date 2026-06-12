{ ... }:

let
  port = 8222;
in
{
  services.vaultwarden = {
    enable = true;
    config = {
      DOMAIN = "https://vault.home.kucendro.dev";
      ROCKET_ADDRESS = "0.0.0.0";
      ROCKET_PORT = port;
      SIGNUPS_ALLOWED = true;
    };
  };

  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ port ];
}
