{ lib, ... }:

let
  publics = {
    party = "nas.ts.kucendro.dev:8095";
    kubicek = "nas.ts.kucendro.dev:3007";
    mcp = "nas.ts.kucendro.dev:8092";
  };

  mkVhost = name: hostPort: {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://$upstream_${name}";
      proxyWebsockets = true;
      extraConfig = ''
        set $upstream_${name} ${hostPort};
        proxy_read_timeout 600s;
        proxy_send_timeout 600s;
      '';
    };
  };
in
{
  services.nginx.virtualHosts = lib.mapAttrs' (
    name: hostPort: lib.nameValuePair "${name}.kucendro.dev" (mkVhost name hostPort)
  ) publics;
}
