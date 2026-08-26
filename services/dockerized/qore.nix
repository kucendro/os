{ ... }:

let
  port = 7673;
in
{
  #: unit qore
  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ port ];
}
