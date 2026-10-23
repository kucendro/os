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
    assistant = {
      host = "mcp.assistant.${me.domains.root}";
      address = nas "home-assistant";
      extraConfig = "proxy_buffering off;";
      paths = [
        "/api/mcp"
        "/auth/"
        "/frontend_latest/"
        "/static/"
        "= /manifest.json"
        "= /.well-known/oauth-authorization-server"
        "= /.well-known/oauth-protected-resource"
      ];
    };
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

  mkProxy = name: cfg: {
    proxyPass = "http://$upstream_${name}";
    proxyWebsockets = true;
    extraConfig = ''
      set $upstream_${name} ${cfg.address};
      ${cfg.extraConfig or ""}
    '';
  };

  mkVhost = name: cfg: {
    enableACME = true;
    forceSSL = true;
    locations =
      if cfg ? paths then
        lib.genAttrs cfg.paths (_: mkProxy name cfg) // { "/".return = "404"; }
      else
        { "/" = mkProxy name cfg; };
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
