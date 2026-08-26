{ config, me, ... }:

{
  #: mesh-node
  #: -> edge/headscale mesh
  services.tailscale = {
    enable = true;
    authKeyFile = config.sops.secrets.tailscale-authkey.path;
    extraUpFlags = [
      "--login-server=https://${me.domains.edge}"
    ];
  };
}
