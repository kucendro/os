{ lib, me, ... }:

let
  nas = "nas.${me.domains.mesh}";

  publics = {
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
  #: -> nas/music-assistant party
  #: -> nas/kubicek kubicek
  services.nginx.virtualHosts = lib.mapAttrs' (
    name: cfg: lib.nameValuePair "${name}.${me.domains.root}" (mkVhost name cfg)
  ) publics;
}
