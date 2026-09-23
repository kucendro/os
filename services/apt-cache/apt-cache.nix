{ pkgs, lib, ... }:

let
  port = 3142;
  hotspot = {
    interface = "wlp98s0";
    ip = "10.42.0.1";
  };
  setup = pkgs.runCommand "apt-cache-setup" { } ''
    install -Dm444 ${
      pkgs.replaceVars ./apt.sh {
        ip = hotspot.ip;
        port = toString port;
      }
    } $out/apt.sh
  '';
in
{
  #: unit apt-packages-cache
  #: expose 3142 lan
  systemd.services.apt-cacher-ng = {
    description = "apt-cacher-ng caching proxy";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      ExecStart = lib.concatStringsSep " " [
        "${pkgs.apt-cacher-ng}/bin/apt-cacher-ng"
        "-c ${pkgs.apt-cacher-ng}/etc/apt-cacher-ng"
        "ForeGround=1"
        "Port=${toString port}"
        "BindAddress=0.0.0.0"
        "CacheDir=/var/cache/apt-cacher-ng"
        "LogDir=/var/log/apt-cacher-ng"
        ''"LocalDirs=setup ${setup}"''
        # "Offlinemode=1"
      ];
      DynamicUser = true;
      CacheDirectory = "apt-cacher-ng";
      LogsDirectory = "apt-cacher-ng";
      Restart = "on-failure";
    };
  };

  networking.firewall.interfaces.${hotspot.interface} = {
    allowedTCPPorts = [
      port
      53
    ];
    allowedUDPPorts = [
      53
      67
    ];
  };

  networking.networkmanager.ensureProfiles.profiles.cache = {
    connection = {
      id = "cache";
      type = "wifi";
      interface-name = hotspot.interface;
      autoconnect = false;
    };
    wifi = {
      mode = "ap";
      ssid = "ubuntu-cache";
      band = "bg";
    };
    wifi-security = {
      key-mgmt = "wpa-psk";
      psk = "afterkirk01";
    };
    ipv4 = {
      method = "shared";
      address1 = "${hotspot.ip}/24";
    };
    ipv6.method = "disabled";
  };
}
