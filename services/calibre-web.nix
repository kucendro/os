{ pkgs, ... }:

let
  port = 8083;
  emptyLibrary =
    pkgs.runCommand "empty-calibre-library"
      {
        nativeBuildInputs = [ pkgs.calibre ];
      }
      ''
        export HOME=$TMPDIR
        calibredb list --with-library $out > /dev/null
      '';
in
{
  #: unit calibre-web
  #: expose 8083 mesh
  #: expose 8083 lan
  services.calibre-web = {
    enable = true;
    listen = {
      ip = "0.0.0.0";
      inherit port;
    };
    options = {
      calibreLibrary = "/mnt/data/shelf";
      enableBookUploading = true;
    };
  };

  systemd.tmpfiles.rules = [
    "d /mnt/data/calibre-web 0700 calibre-web calibre-web -"
    "d /mnt/data/shelf 0750 calibre-web calibre-web -"
    "C /mnt/data/shelf/metadata.db 0640 calibre-web calibre-web - ${emptyLibrary}/metadata.db"
  ];

  fileSystems."/var/lib/calibre-web" = {
    device = "/mnt/data/calibre-web";
    fsType = "none";
    options = [ "bind" ];
  };

  systemd.services.calibre-web.unitConfig.RequiresMountsFor = [
    "/var/lib/calibre-web"
    "/mnt/data/shelf"
  ];

  networking.firewall.interfaces = {
    "tailscale0".allowedTCPPorts = [ port ];
    "enp1s0".allowedTCPPorts = [ port ];
    "enp3s0".allowedTCPPorts = [ port ];
  };
}
