{ config, me, ... }:

let
  guiPort = 8384;
  syncPort = 22000;
in
{
  services.syncthing = {
    enable = true;
    dataDir = "/mnt/data/syncthing";
    guiAddress = "0.0.0.0:${toString guiPort}";

    overrideDevices = true;
    overrideFolders = true;

    settings = {
      options = {
        urAccepted = -1;
        globalAnnounceEnabled = false;
        relaysEnabled = false;
        natEnabled = false;
      };
      devices = {
        nixbook = {
          id = "WVEIFL3-ZPPU7BB-BDBW52J-OMZRSRO-QUTOL6F-Q5RDSUO-DGU6TVO-G7457AU";
          addresses = [
            "tcp://nixbook.${me.domains.mesh}:${toString config.nodes.nixbook.mesh.ports.syncthing}"
          ];
        };
        fold = {
          id = "JHIZPBP-NPI5FXX-PGAH3IM-AZ3J4IG-44ELB4E-ENDRQL3-QRBGXJB-GIIGDQW";
          addresses = [ "tcp://fold.${me.domains.mesh}:${toString syncPort}" ];
        };
        mac = {
          id = "OYN5NMI-G4YU6F5-66F5UL7-3MZGO6G-IS6CWMD-LYK6ANT-3HX6IBN-WVREHAV";
          addresses = [ "tcp://mac.${me.domains.mesh}:${toString syncPort}" ];
        };
      };
      folders =
        let
          shared = name: {
            path = "/mnt/data/syncthing/${name}";
            devices = [
              "nixbook"
              "fold"
              "mac"
            ];
          };
        in
        {
          documents = shared "documents";
          screenshots = shared "screenshots";
          knowledge = shared "knowledge";
          drop = shared "drop";
        };
    };
  };

  nixdiag.units.syncthing = {
    ports = [ guiPort ];
    expose = [
      {
        port = syncPort;
        scope = "mesh";
      }
    ];
  };

  systemd.services.syncthing.unitConfig.RequiresMountsFor = [ "/mnt/data" ];

  mesh = {
    ports = {
      syncthing = syncPort;
      syncthing-gui = guiPort;
    };
    udp = [ syncPort ];
  };
}
