{ config, ... }:

let
  port = 45876;
in
{
  services.beszel.agent = {
    enable = true;
    openFirewall = false;
    environmentFile = config.sops.templates."beszel-agent-env".path;
  };

  nixdiag.units.beszel-agent = { };

  mesh.ports.beszel-agent = port;
}
