{ ... }:

{
  services.nginx.virtualHosts."party.kucendro.dev" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://$party_upstream";
      proxyWebsockets = true;
      extraConfig = ''
        set $party_upstream nas.ts.kucendro.dev:8095;
        proxy_read_timeout 600s;
        proxy_send_timeout 600s;
      '';
    };
  };
}
