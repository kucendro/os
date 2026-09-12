{ ... }:

let
  lanInterface = "wlp2s0";
  threadInterface = "wpan0";
  device = "/dev/zbt2";
  restPort = 8081;
  webPort = 8082;
in
{
  virtualisation.oci-containers = {
    backend = "docker";

    #: unit otbr
    containers.otbr = {
      image = "openthread/border-router:latest";
      autoStart = false;
      volumes = [ "/mnt/data/otbr:/data" ];

      devices = [
        "${device}:${device}"
        "/dev/net/tun:/dev/net/tun"
      ];
      capabilities.NET_ADMIN = true;

      environment = {
        OT_RCP_DEVICE = "spinel+hdlc+uart://${device}?uart-baudrate=460800&uart-flow-control";
        OT_INFRA_IF = lanInterface;
        OT_THREAD_IF = threadInterface;
        OT_LOG_LEVEL = "5";
        OT_REST_LISTEN_ADDR = "127.0.0.1";
        OT_REST_LISTEN_PORT = toString restPort;
        OT_WEB_LISTEN_ADDR = "127.0.0.1";
        OT_WEB_LISTEN_PORT = toString webPort;
      };

      extraOptions = [ "--network=host" ];
    };
  };

  services.udev.extraRules = ''
    SUBSYSTEM=="tty", ATTRS{idVendor}=="303a", ATTRS{idProduct}=="4001|831a", SYMLINK+="zbt2", TAG+="systemd", ENV{SYSTEMD_WANTS}+="docker-otbr.service"
  '';

  systemd.services.docker-otbr = {
    bindsTo = [ "dev-zbt2.device" ];
    after = [ "dev-zbt2.device" ];
    unitConfig.RequiresMountsFor = [ "/mnt/data" ];
  };

  boot.kernelModules = [
    "ip6table_filter"
    "ip_set_hash_net"
    "xt_set"
    "xt_pkttype"
  ];

  boot.kernel.sysctl = {
    "net.ipv6.conf.all.forwarding" = true;
    "net.ipv6.conf.${lanInterface}.accept_ra" = 2;
    "net.ipv6.conf.${lanInterface}.accept_ra_rt_info_max_plen" = 64;
  };

  systemd.tmpfiles.rules = [
    "d /mnt/data/otbr 0700 root root -"
  ];

  networking.firewall.trustedInterfaces = [ threadInterface ];
}
