{ ... }:

{
  services.beszel.hub = {
    enable = true;
    host = "127.0.0.1";
    port = 8090;
  };

  nixdiag.units.beszel = {
    role = "monitor";
    ports = [ 8090 ];
  };
}
