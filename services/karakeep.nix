{ me, ... }:

let
  port = 3006;
  domain = "karakeep.${me.domains.home}";
in
{
  nixpkgs.config.permittedInsecurePackages = [ "pnpm-9.15.9" ];

  services.karakeep = {
    enable = true;
    extraEnvironment = {
      PORT = toString port;
      NEXTAUTH_URL = "https://${domain}";
      DISABLE_NEW_RELEASE_CHECK = "true";
      CRAWLER_FULL_PAGE_ARCHIVE = "true";
      CRAWLER_VIDEO_DOWNLOAD = "true";
      CRAWLER_VIDEO_DOWNLOAD_MAX_SIZE = "-1";
    };
  };

  nixdiag.units.karakeep.ports = [ port ];

  systemd.tmpfiles.rules = [
    "d /mnt/data/karakeep 0700 karakeep karakeep -"
  ];

  fileSystems."/var/lib/karakeep" = {
    device = "/mnt/data/karakeep";
    fsType = "none";
    options = [ "bind" ];
  };

  systemd.services.karakeep-init.unitConfig.RequiresMountsFor = [ "/var/lib/karakeep" ];
  systemd.services.karakeep-workers.unitConfig.RequiresMountsFor = [ "/var/lib/karakeep" ];
  systemd.services.karakeep-web.unitConfig.RequiresMountsFor = [ "/var/lib/karakeep" ];

  mesh.ports.karakeep = port;
}
