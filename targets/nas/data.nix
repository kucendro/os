{ pkgs, ... }:

# Data pool for the NAS — SSD-only, btrfs.
#
# NOT imported by default.nix yet. Enable it once a data SSD is physically
# connected: add `./data.nix` to the imports in targets/nas/default.nix and
# set the by-id device path below.
#
# Why btrfs (not ZFS): the array grows by adding random, mixed-size SSDs over
# time. btrfs RAID1 stores two copies on ANY two devices regardless of size,
# and disks are added live — ZFS/mdadm both struggle with mismatched disks.
# Use RAID1 for redundancy; never btrfs RAID5/6 (still not production-safe).
#
# ── First provision (DESTRUCTIVE, create-once) ───────────────────────────────
#   disko's `create` mode formats `disk.data`. After that, NEVER re-run destroy
#   mode against this disk — grow the pool imperatively (see below).
#
# ── Add another SSD later (online, non-destructive) ──────────────────────────
#   sudo btrfs device add /dev/disk/by-id/<NEW-SSD> /mnt/data
#   # convert to RAID1 so every block has a copy on a second device:
#   sudo btrfs balance start -dconvert=raid1 -mconvert=raid1 /mnt/data
#   sudo btrfs filesystem usage /mnt/data    # verify
#
#   (Repeat `device add` for each new SSD; re-balance keeps RAID1 invariant.)

{
  disko.devices.disk.data = {
    type = "disk";
    # TODO: set to the real data SSD, e.g. /dev/disk/by-id/ata-Samsung_SSD_...
    device = "/dev/disk/by-id/REPLACE-ME";
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
              ];
            };
            "/@snapshots" = {
              mountpoint = "/mnt/data/.snapshots";
              mountOptions = [
                "compress=zstd"
                "noatime"
              ];
            };
          };
        };
      };
    };
  };

  boot.supportedFilesystems = [ "btrfs" ];

  # Weekly integrity scrub — catches and (with RAID1) self-heals bit-rot.
  services.btrfs.autoScrub = {
    enable = true;
    interval = "weekly";
    fileSystems = [ "/mnt/data" ];
  };

  environment.systemPackages = [ pkgs.btrfs-progs ];

  # TRIM is already handled globally by services.fstrim (services/services.nix),
  # so no continuous `discard` mount option is needed.
}
