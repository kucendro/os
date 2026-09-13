{ lib, ... }:

let
  lanInterface = "wlp2s0";
  threadInterface = "wpan0";
  device = "/dev/zbt2";
in
{
  services.openthread-border-router = {
    enable = true;
    backboneInterfaces = [ lanInterface ];
    interfaceName = threadInterface;
    logLevel = "notice";
    radio = {
      inherit device;
      baudRate = 460800;
      flowControl = true;
    };
  };

  services.udev.extraRules = ''
    SUBSYSTEM=="tty", ATTRS{idVendor}=="303a", ATTRS{idProduct}=="4001|831a", SYMLINK+="zbt2", TAG+="systemd", ENV{SYSTEMD_WANTS}+="otbr-agent.service"
  '';

  systemd.services.otbr-agent = {
    wantedBy = lib.mkForce [ ];
    bindsTo = [ "dev-zbt2.device" ];
    after = [ "dev-zbt2.device" ];
  };

  boot.kernelModules = [
    "ip6table_filter"
    "ip_set_hash_net"
    "xt_set"
    "xt_pkttype"
  ];

  networking.firewall.trustedInterfaces = [ threadInterface ];
}
