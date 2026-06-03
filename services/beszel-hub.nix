{ config, ... }:

{
  services.beszel.hub = {
    enable = true;
    host = "127.0.0.1";
    port = 8090;
  };

  security.acme.certs."home.kucendro.dev" = {
    domain = "home.kucendro.dev";
    extraDomainNames = [ "*.home.kucendro.dev" ];
    dnsProvider = "cloudflare";
    environmentFile = config.sops.templates."acme-cloudflare-env".path;
    group = "nginx";
  };

  services.nginx.virtualHosts."monitoring.home.kucendro.dev" = {
    useACMEHost = "home.kucendro.dev";
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:8090";
      proxyWebsockets = true;
    };
  };
}
