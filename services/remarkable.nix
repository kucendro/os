{ me, ... }:

let
  port = 5007;
in
{
  services.rmfakecloud = {
    enable = true;
    port = port;
    storageUrl = "https://remarkable.${me.domains.home}";
    logLevel = "warn";
  };

  systemd.tmpfiles.rules = [
    "d /mnt/data/remarkable 0700 - - -"
  ];

  fileSystems."/var/lib/private/rmfakecloud" = {
    device = "/mnt/data/remarkable";
    fsType = "none";
    options = [ "bind" ];
  };

  systemd.services.rmfakecloud.unitConfig.RequiresMountsFor = [ "/var/lib/private/rmfakecloud" ];
  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ port ];
}
