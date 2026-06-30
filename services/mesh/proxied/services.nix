{ lib, ... }:

let
  homeDomain = "home.kucendro.dev";
  tailnetIP = "100.64.0.1";

  upstreams = {
    monitoring = "127.0.0.1:8090";
    music = "nas.ts.kucendro.dev:8095";
    vault = "nas.ts.kucendro.dev:8222";
    gallery = "nas.ts.kucendro.dev:2283";
    grafana = "nas.ts.kucendro.dev:3000";
    git = "nas.ts.kucendro.dev:3001";
    assistant = "nas.ts.kucendro.dev:8123";
    cameras = "nas.ts.kucendro.dev:5000";
    qore = "nas.ts.kucendro.dev:7673";
    health = "nas.ts.kucendro.dev:3005";
    healthapi = "nas.ts.kucendro.dev:8000"; # open-wearables API (API_PORT)
  };

  mkVhost = name: hostPort: {
    listenAddresses = [ tailnetIP ];
    useACMEHost = homeDomain;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://$upstream_${name}";
      proxyWebsockets = true;
      extraConfig = ''
        set $upstream_${name} ${hostPort};
      '';
    };
  };
in
{
  services.nginx.resolver = {
    addresses = [ "100.100.100.100" ]; # tailscale MagicDNS
    valid = "30s";
    ipv6 = false;
  };

  services.nginx.virtualHosts = lib.mapAttrs' (
    name: hostPort: lib.nameValuePair "${name}.${homeDomain}" (mkVhost name hostPort)
  ) upstreams;
}
