{ ... }:

{
  services.immich = {
    enable = true;
    host = "0.0.0.0";
    port = 2283;
    mediaLocation = "/mnt/data/immich";
  };

  systemd.services.immich-server.unitConfig.RequiresMountsFor = [ "/mnt/data" ];
  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ 2283 ];
}
