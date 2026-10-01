{ ... }:

let
  port = 2283;
in
{
  services.immich = {
    enable = true;
    host = "0.0.0.0";
    inherit port;
    mediaLocation = "/mnt/data/immich";
  };

  nixdiag.units.immich.ports = [ port ];

  systemd.services.immich-server.unitConfig.RequiresMountsFor = [ "/mnt/data" ];
  mesh.ports.immich = port;
}
