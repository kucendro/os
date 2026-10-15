{ me, ... }:

let
  port = 8971;
  reverseProxyIP = "100.64.0.1";
  hostname = "cameras.${me.domains.home}";
  dataDir = "/mnt/data/frigate";
in
{
  services.frigate = {
    enable = true;
    inherit hostname;

    settings = {
      auth = {
        cookie_secure = true;
        trusted_proxies = [
          "127.0.0.1"
          reverseProxyIP
        ];
      };
      detectors.cpu1.type = "cpu";
      cameras = { };
    };
  };

  services.nginx.virtualHosts.${hostname}.listen = [
    {
      addr = "0.0.0.0";
      inherit port;
    }
  ];

  nixdiag.units.frigate = {
    ports = [ port ];
    names = [
      "frigate-api"
      "frigate-go2rtc"
      "frigate-jsmpeg"
      "frigate-mqtt-ws"
    ];
  };

  systemd.services.frigate.unitConfig.RequiresMountsFor = [ "/var/lib/frigate" ];

  systemd.tmpfiles.rules = [
    "d ${dataDir} 0750 frigate frigate -"
  ];

  fileSystems."/var/lib/frigate" = {
    device = dataDir;
    fsType = "none";
    options = [ "bind" ];
  };

  mesh.ports.frigate = port;
}
