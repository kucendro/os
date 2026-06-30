{ ... }:

let
  frontendPort = 3005;
  apiPort = 8000;
in
{
  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [
    frontendPort
    apiPort
  ];
}
