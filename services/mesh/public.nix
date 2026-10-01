{
  config,
  lib,
  me,
  ...
}:

let
  nas = name: "nas.${me.domains.mesh}:${toString config.nodes.nas.mesh.ports.${name}}";

  publics = {
    portfolio = {
      host = me.domains.root;
      address = nas "portfolio";
    };
    archive = {
      address = nas "portfolio";
    };
    party = {
      address = nas "music-assistant";
    };
    kubicek = {
      address = nas "kubicek";
    };
    # mcp = {
    #   address = nas "mcp-gitea";
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
  services.nginx.virtualHosts =
    lib.mapAttrs' (
      name: cfg: lib.nameValuePair (cfg.host or "${name}.${me.domains.root}") (mkVhost name cfg)
    ) publics
    // lib.genAttrs alts (_: mkRedirect);

  nixdiag.units.nginx.connections = lib.mapAttrsToList (name: cfg: {
    to = cfg.address;
    label = "${name} :${lib.last (lib.splitString ":" cfg.address)}";
  }) publics;
}
