{ pkgs, ... }:

{
  services.immich = {
    enable = true;
    host = "0.0.0.0";
    port = 2283;

    mediaLocation = "/mnt/data/immich";

  };
  systemd.services.immich-server.unitConfig.RequiresMountsFor = [ "/mnt/data" ];
  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ 2283 ];

  # Due the migration from Umbrel, the media needed to be transfered to ext mount.
  systemd.services.immich-fix-media-perms = {
    description = "Ensure Immich media dir exists and is owned by immich on the external mount";
    after = [ "mnt-data.mount" ];
    requires = [ "mnt-data.mount" ];
    before = [ "immich-server.service" ];
    requiredBy = [ "immich-server.service" ];
    unitConfig.RequiresMountsFor = [ "/mnt/data" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = [
        "${pkgs.coreutils}/bin/install -d -o immich -g immich -m 0750 /mnt/data/immich"
        "${pkgs.coreutils}/bin/chown -R immich:immich /mnt/data/immich"
      ];
    };
  };
}
