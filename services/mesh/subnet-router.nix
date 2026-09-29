let
  lan = "192.168.1.0/24";
in
{
  services.tailscale = {
    useRoutingFeatures = "server";
    extraSetFlags = [ "--advertise-routes=${lan}" ];
  };

  nixdiag.networks.lan.cidrs = [ lan ];
}
