{ ... }:

let
  port = 7673;
in
{
  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ port ];

  nixdiag.units.qore.ports = [ port ];
}
