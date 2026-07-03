{ lib, ... }:

let
  homeDomain = "home.kucendro.dev";
  tailnetIP = "100.64.0.1";
  upstreams = import ./endpoints.nix;
  mkVhost = name: hostPort: {
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
        set $upstream_${name} ${hostPort};
        proxy_read_timeout 600s;
        proxy_send_timeout 600s;
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
    name: hostPort: lib.nameValuePair "${name}.${homeDomain}" (mkVhost name hostPort)
  ) upstreams;
}
