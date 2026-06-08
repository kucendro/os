{ ... }:

# OS disk layout, curated like targets/edge/disko.nix.
# This only declares the boot/root disk — data disks (ZFS/btrfs pool etc.)
# can be added as extra `disk.*` entries later.
#
# IMPORTANT: set `device` to the real NAS boot disk before deploying.
# Find it with `lsblk -o NAME,SIZE,MODEL` on the box. Real hardware is
# usually NVMe (/dev/nvme0n1) or SATA (/dev/sda).

{
  disko.devices = {
    disk.main = {
      type = "disk";
      device = "/dev/sda";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            size = "512M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "umask=0077" ];
            };
          };
          root = {
            size = "100%";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
            };
          };
        };
      };
    };
  };
}
