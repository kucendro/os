{ config, me, ... }:

let
  syncPort = 22000;
in
{
  services.syncthing = {
    enable = true;
    user = me.name;
    group = "users";
    dataDir = "/home/${me.name}";

    overrideDevices = true;
    overrideFolders = true;

    settings = import ./settings.nix { inherit config me; };
  };

  nixdiag.units.syncthing.connections = [
    {
      to = "nas/syncthing";
      label = "sync";
    }
  ];

  mesh = {
    ports.syncthing = syncPort;
    udp = [ syncPort ];
  };
}
