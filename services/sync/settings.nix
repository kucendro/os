{ config, me }:

let
  syncPort = 22000;
  home = config.users.users.${me.name}.home;
  shared = path: {
    inherit path;
    devices = [
      "nas"
      "fold"
    ];
  };
in
{
  options = {
    urAccepted = -1;
    globalAnnounceEnabled = false;
    relaysEnabled = false;
    natEnabled = false;
  };
  devices = {
    nas = {
      id = "TCH5BXD-5XBUVYJ-WKEMZCL-JEQXSGZ-NHTKQJT-OWEZ2NU-P7RFVLY-YUA7FAG";
      addresses = [ "tcp://nas.${me.domains.mesh}:${toString config.nodes.nas.mesh.ports.syncthing}" ];
    };
    fold = {
      id = "JHIZPBP-NPI5FXX-PGAH3IM-AZ3J4IG-44ELB4E-ENDRQL3-QRBGXJB-GIIGDQW";
      addresses = [ "tcp://fold.${me.domains.mesh}:${toString syncPort}" ];
    };
  };
  folders = {
    documents = shared "${home}/Documents";
    screenshots = shared "${home}/screenshots";
    knowledge = shared "${home}/knowledge";
    drop = shared "${home}/drop";
  };
}
