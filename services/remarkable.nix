{ ... }:

let
  port = 5007;
in
{
  services.rmfakecloud = {
    enable = true;
    port = port;
    storageUrl = "https://remarkable.home.kucendro.dev";
    logLevel = "warn";
  };

  systemd.tmpfiles.rules = [
    "d /mnt/data/remarkable 0700 root root -"
  ];

  fileSystems."/var/lib/rmfakecloud" = {
    device = "/mnt/data/remarkable";
    fsType = "none";
    options = [ "bind" ];
  };

  systemd.services.rmfakecloud.unitConfig.RequiresMountsFor = [ "/var/lib/rmfakecloud" ];
  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ port ];
}
