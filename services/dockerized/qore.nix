{ ... }:

let
  port = 7673;
in
{
  nixdiag.units.qore.ports = [ port ];

  mesh.ports.qore = port;
}
