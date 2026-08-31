{ me, ... }:

let
  guiPort = 8384;
  syncPort = 22000;
in
{
  #: unit syncthing
  #: expose 22000 mesh
  services.syncthing = {
    enable = true;
    dataDir = "/mnt/data/syncthing";
    guiAddress = "0.0.0.0:${toString guiPort}";

    overrideDevices = false;
    overrideFolders = false;

    settings = {
      options = {
        urAccepted = -1;
        globalAnnounceEnabled = false;
        relaysEnabled = false;
        natEnabled = false;
      };
      # devices.nixbook = {
      #   id = "DEVICE-ID-FROM-syncthing --device-id";
      #   addresses = [ "tcp://nixbook.${me.domains.mesh}:${toString syncPort}" ];
      # };
      # folders.sync = {
      #   path = "/mnt/data/syncthing/sync";
      #   devices = [ "nixbook" ];
      # };
    };
  };

  systemd.services.syncthing.unitConfig.RequiresMountsFor = [ "/mnt/data" ];

  networking.firewall.interfaces."tailscale0" = {
    allowedTCPPorts = [
      guiPort
      syncPort
    ];
    allowedUDPPorts = [ syncPort ];
  };
}
