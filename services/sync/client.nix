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
      devices = {
        nas = {
          id = "TCH5BXD-5XBUVYJ-WKEMZCL-JEQXSGZ-NHTKQJT-OWEZ2NU-P7RFVLY-YUA7FAG";
          addresses = [ "tcp://nas.${me.domains.mesh}:${toString syncPort}" ];
        };
        fold = {
          id = "JHIZPBP-NPI5FXX-PGAH3IM-AZ3J4IG-44ELB4E-ENDRQL3-QRBGXJB-GIIGDQW";
          addresses = [ "tcp://fold.${me.domains.mesh}:${toString syncPort}" ];
        };
      };
      folders =
        let
          shared = path: {
            inherit path;
            devices = [
              "nas"
              "fold"
            ];
          };
        in
        {
          documents = shared "/home/${me.name}/Documents";
          screenshots = shared "/home/${me.name}/screenshots";
          knowledge = shared "/home/${me.name}/knowledge";
          drop = shared "/home/${me.name}/drop";
        };
    };
  };

  networking.firewall.interfaces."tailscale0" = {
    allowedTCPPorts = [ syncPort ];
    allowedUDPPorts = [ syncPort ];
  };

}
