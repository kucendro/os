{ ... }:

let
  port = 7673;
in
{
  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ port ];
}
