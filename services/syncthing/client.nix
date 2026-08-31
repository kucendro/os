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

    overrideDevices = false;
    overrideFolders = false;

    settings = {
      options = {
        urAccepted = -1;
        globalAnnounceEnabled = false;
        relaysEnabled = false;
        natEnabled = false;
      };
      # devices.nas = {
      #   id = "DEVICE-ID-FROM-syncthing --device-id";
      #   addresses = [ "tcp://nas.${me.domains.mesh}:${toString syncPort}" ];
      # };
      # folders.sync = {
      #   path = "/home/${me.name}/sync";
      #   devices = [ "nas" ];
      # };
    };
  };

  networking.firewall.interfaces."tailscale0" = {
    allowedTCPPorts = [ syncPort ];
    allowedUDPPorts = [ syncPort ];
  };
}
