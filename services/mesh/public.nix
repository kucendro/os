{ lib, ... }:

let
  publics = {
    party = {
      address = "nas.ts.kucendro.dev:8095";
    };
    kubicek = {
      address = "nas.ts.kucendro.dev:3007";
    };
    # mcp = {
    #   address = "nas.ts.kucendro.dev:8092";
    #   extraConfig = "proxy_buffering off;";
    # };
  };

  mkVhost = name: cfg: {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://$upstream_${name}";
      proxyWebsockets = true;
      extraConfig = ''
        set $upstream_${name} ${cfg.address};
        proxy_read_timeout 600s;
        proxy_send_timeout 600s;
        ${cfg.extraConfig or ""}
      '';
    };
  };
in
{
  services.nginx.virtualHosts = lib.mapAttrs' (
    name: cfg: lib.nameValuePair "${name}.kucendro.dev" (mkVhost name cfg)
  ) publics;
}
