{
  #: -> lan advertise 192.168.1.0/24
  services.tailscale = {
    useRoutingFeatures = "server";
    extraSetFlags = [ "--advertise-routes=192.168.1.0/24" ];
  };
}
