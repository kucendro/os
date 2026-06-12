{ lib, ... }:

let
  homeDomain = "home.kucendro.dev";
  tailnetIP = "100.64.0.1";

  upstreams = {
    monitoring = "http://127.0.0.1:8090";
    music = "http://nas.ts.kucendro.dev:8095";
  };

  mkVhost = upstream: {
    listenAddresses = [ tailnetIP ];
    useACMEHost = homeDomain;
    forceSSL = true;
    locations."/" = {
      proxyPass = upstream;
      proxyWebsockets = true;
    };
  };
in
{
  services.nginx.virtualHosts = lib.mapAttrs' (
    name: upstream: lib.nameValuePair "${name}.${homeDomain}" (mkVhost upstream)
  ) upstreams;
}
