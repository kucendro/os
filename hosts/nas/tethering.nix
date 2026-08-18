{ pkgs, ... }:

{
  services.usbmuxd.enable = true;

  services.udev.extraRules = ''
    SUBSYSTEM=="net", ACTION=="add", DRIVERS=="ipheth", NAME="iphone0"
  '';

  networking.networkmanager.ensureProfiles.profiles.iphone-wan = {
    connection = {
      id = "iphone-wan";
      type = "ethernet";
      interface-name = "iphone0";
      autoconnect = true;
    };
    ipv4 = {
      method = "auto";
      route-metric = 700;
    };
    ipv6.method = "ignore";
  };

  systemd.services.iphone-keepalive = {
    description = "Keep hotspot alive";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "iphone-keepalive" ''
        ${pkgs.iproute2}/bin/ip link show iphone0 >/dev/null 2>&1 || exit 0
        exec ${pkgs.iputils}/bin/ping -I iphone0 -c1 -W5 -n 1.1.1.1
      '';
    };
  };

  systemd.timers.iphone-keepalive = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "1min";
      OnUnitActiveSec = "30s";
    };
  };
}
