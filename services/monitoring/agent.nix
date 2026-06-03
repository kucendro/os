{ config, ... }:

{
  services.beszel.agent = {
    enable = true;
    environmentFile = config.sops.templates."beszel-agent-env".path;
  };
}
