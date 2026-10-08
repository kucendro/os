{ ... }:

let
  port = 2283;
  mediaLocation = "/mnt/data/immich";
in
{
  services.immich = {
    enable = true;
    host = "0.0.0.0";
    inherit port mediaLocation;
  };

  systemd.tmpfiles.rules = [ "d ${mediaLocation} 0700 immich immich -" ];

  nixdiag.units.immich.ports = [ port ];

  systemd.services.immich-server.unitConfig.RequiresMountsFor = [ "/mnt/data" ];
  mesh.ports.immich = port;
}
