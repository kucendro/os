{ me, ... }:

let
  syncPort = 22000;
in
{
  #: unit syncthing
  #: -> nas/syncthing sync
  services.syncthing = {
    enable = true;
    user = me.name;
    group = "users";
    dataDir = "/home/${me.name}";

    overrideDevices = true;
    overrideFolders = true;

    settings = {
      options = {
        urAccepted = -1;
        globalAnnounceEnabled = false;
        relaysEnabled = false;
        natEnabled = false;
      };
      devices.nas = {
        id = "TCH5BXD-5XBUVYJ-WKEMZCL-JEQXSGZ-NHTKQJT-OWEZ2NU-P7RFVLY-YUA7FAG";
        addresses = [ "tcp://nas.${me.domains.mesh}:${toString syncPort}" ];
      };
      folders.sync = {
        path = "/home/${me.name}/sync";
        devices = [ "nas" ];
      };
    };
  };

  networking.firewall.interfaces."tailscale0" = {
    allowedTCPPorts = [ syncPort ];
    allowedUDPPorts = [ syncPort ];
  };
}
