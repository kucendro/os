{ ... }:

let
  port = 5006;
in
{
  services.actual = {
    enable = true;
    settings.port = port;
  };

  systemd.tmpfiles.rules = [
    "d /mnt/data/actual 0700 root root -"
  ];

  fileSystems."/var/lib/actual" = {
    device = "/mnt/data/actual";
    fsType = "none";
    options = [ "bind" ];
  };

  systemd.services.actual.unitConfig.RequiresMountsFor = [ "/var/lib/actual" ];
  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ port ];
}
