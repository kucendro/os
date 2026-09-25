{ me, ... }:

let
  tailnetIP = "100.64.0.1";
in
{
  #: -> nas/nginx dev :7000 name=dev@root:443
  services.nginx.virtualHosts."*.dev.${me.domains.root}" = {
    listenAddresses = [ tailnetIP ];
    useACMEHost = me.domains.home;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://$upstream_dev";
      proxyWebsockets = true;
      extraConfig = "set $upstream_dev nas.${me.domains.mesh}:7000;";
    };
  };
}
