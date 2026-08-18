{ pkgs, ... }:

{
  disko.devices.disk.data = {
    type = "disk";
    device = "/dev/disk/by-id/ata-KINGSTON_SKC6002048G_50026B77836F78D9";
    content = {
      type = "gpt";
      partitions.data = {
        size = "100%";
        content = {
          type = "btrfs";
          extraArgs = [
            "-L"
            "data"
            "-f"
          ];
          subvolumes = {
            "/@data" = {
              mountpoint = "/mnt/data";
              mountOptions = [
                "compress=zstd"
                "noatime"
                "nofail"
              ];
            };
            "/@snapshots" = {
              mountpoint = "/mnt/data/.snapshots";
              mountOptions = [
                "compress=zstd"
                "noatime"
                "nofail"
              ];
            };
          };
        };
      };
    };
  };

  boot.supportedFilesystems = [ "btrfs" ];

  services.btrfs.autoScrub = {
    enable = true;
    interval = "weekly";
    fileSystems = [ "/mnt/data" ];
  };

  virtualisation.docker.daemon.settings.data-root = "/mnt/data/docker";
  systemd.services.docker.unitConfig.RequiresMountsFor = [ "/mnt/data" ];

  environment.systemPackages = [ pkgs.btrfs-progs ];
}
