{ lib, me, ... }:

let
  homeDomain = me.domains.home;
  tailnetIP = "100.64.0.1";
  upstreams = import ./endpoints.nix me;
  mkVhost = name: cfg: {
    listenAddresses = [ tailnetIP ];
    useACMEHost = homeDomain;
    forceSSL = true;
    extraConfig = ''
      client_max_body_size 0;
    '';
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
  services.nginx.resolver = {
    addresses = [ "100.100.100.100" ];
    valid = "30s";
    ipv6 = false;
  };

  #: -> edge/beszel monitoring :8090
  #: -> nas/music-assistant music :8095
  #: -> nas/vaultwarden vault :8222
  #: -> nas/immich gallery :2283
  #: -> nas/grafana grafana :3000
  #: -> nas/gitea git :3001
  #: -> nas/home-assistant assistant :8123
  #: -> nas/frigate cameras :5000
  #: -> nas/qore qore :7673
  #: -> nas/ledfx ledfx :8888
  #: -> nas/open-webui chat :8080
  #: -> nas/karakeep karakeep :3006
  #: -> nas/actual budget :5006
  #: -> nas/rmfakecloud remarkable :5007
  #: -> nas/mcp mcp :8092
  services.nginx.virtualHosts = lib.mapAttrs' (
    name: cfg: lib.nameValuePair "${name}.${homeDomain}" (mkVhost name cfg)
  ) upstreams;
}
