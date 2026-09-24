{ lib, me, ... }:

let
  nas = "nas.${me.domains.mesh}";

  publics = {
    portfolio = {
      host = me.domains.root;
      address = "${nas}:80";
    };
    archive = {
      address = "${nas}:80";
    };
    party = {
      address = "${nas}:8095";
    };
    kubicek = {
      address = "${nas}:3007";
    };
    # mcp = {
    #   address = "${nas}:8092";
    #   extraConfig = "proxy_buffering off;";
    # };
  };

  alts = lib.concatMap (d: [
    d
    "www.${d}"
  ]) me.altDomains;

  mkRedirect = {
    enableACME = true;
    forceSSL = true;
    globalRedirect = me.domains.root;
  };

  mkVhost = name: cfg: {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://$upstream_${name}";
      proxyWebsockets = true;
      extraConfig = ''
        set $upstream_${name} ${cfg.address};
        ${cfg.extraConfig or ""}
      '';
    };
  };
in
{
  #: -> nas/nginx portfolio
  #: -> nas/nginx archive
  #: -> nas/music-assistant party
  #: -> nas/kubicek kubicek
  services.nginx.virtualHosts =
    lib.mapAttrs' (
      name: cfg: lib.nameValuePair (cfg.host or "${name}.${me.domains.root}") (mkVhost name cfg)
    ) publics
    // lib.genAttrs alts (_: mkRedirect);
}
