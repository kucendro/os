{ ... }:

let
  port = 8090;
in
{
  services.beszel.hub = {
    enable = true;
    host = "127.0.0.1";
    inherit port;
  };

  nixdiag.units.beszel = {
    role = "monitor";
    ports = [ port ];
  };
}
