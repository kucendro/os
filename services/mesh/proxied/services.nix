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

  services.nginx.virtualHosts = lib.mapAttrs' (
    name: cfg: lib.nameValuePair "${name}.${homeDomain}" (mkVhost name cfg)
  ) upstreams;
}
