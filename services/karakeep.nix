{ ... }:

let
  port = 3006;
  domain = "karakeep.home.kucendro.dev";
in
{
  nixpkgs.config.permittedInsecurePackages = [ "pnpm-9.15.9" ];

  services.karakeep = {
    enable = true;
    extraEnvironment = {
      PORT = toString port;
      NEXTAUTH_URL = "https://${domain}";
      DISABLE_NEW_RELEASE_CHECK = "true";
    };
  };

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

  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ port ];
}
