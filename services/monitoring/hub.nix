{ ... }:

{
  # The beszel hub itself. Its public ingress (monitoring.home.kucendro.dev) is
  # declared with the other *.home reverse proxies in ../mesh/proxied/services.nix.
  services.beszel.hub = {
    enable = true;
    host = "127.0.0.1";
    port = 8090;
  };
}
