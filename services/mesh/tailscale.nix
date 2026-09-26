{ config, me, ... }:

{
  services.tailscale = {
    enable = true;
    authKeyFile = config.sops.secrets.tailscale-authkey.path;
    extraUpFlags = [
      "--login-server=https://${me.domains.edge}"
    ];
  };
}
