{ config, me, ... }:

let
  port = 27701;
in
{
  services.anki-sync-server = {
    enable = true;
    address = "0.0.0.0";
    inherit port;
    users = [
      {
        username = me.name;
        passwordFile = config.sops.secrets.password.path;
      }
    ];
  };

  nixdiag.units.anki-sync-server.ports = [ port ];

  systemd.tmpfiles.rules = [
    "d /mnt/data/flashcards 0700 - - -"
  ];

  fileSystems."/var/lib/private/anki-sync-server" = {
    device = "/mnt/data/flashcards";
    fsType = "none";
    options = [ "bind" ];
  };

  systemd.services.anki-sync-server.unitConfig.RequiresMountsFor = [
    "/var/lib/private/anki-sync-server"
  ];

  mesh.ports.anki-sync-server = port;
}
