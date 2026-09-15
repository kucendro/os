{ config, pkgs, ... }:

let
  source = "/mnt/data/.snapshots/restic";
  btrfs = "${pkgs.btrfs-progs}/bin/btrfs";
in
{
  services.postgresqlBackup.enable = true;

  #: unit restic-backups-hetzner
  services.restic.backups.hetzner = {
    repositoryFile = config.sops.secrets.restic-repository.path;
    passwordFile = config.sops.secrets.restic-password.path;
    extraOptions = [
      "sftp.args='-p 23 -i /etc/ssh/ssh_host_ed25519_key -o StrictHostKeyChecking=accept-new'"
    ];
    initialize = true;
    paths = [
      source
      "/var/backup/postgresql"
      "/var/backup/vaultwarden"
      "/var/lib/karakeep"
    ];
    exclude = [
      "${source}/docker"
      "${source}/immich/thumbs"
      "${source}/immich/encoded-video"
    ];
    backupPrepareCommand = ''
      ${btrfs} subvolume delete ${source} 2>/dev/null || true
      ${btrfs} subvolume snapshot -r /mnt/data ${source}
    '';
    backupCleanupCommand = ''
      ${btrfs} subvolume delete ${source}
    '';
    pruneOpts = [
      "--keep-daily 14"
      "--keep-weekly 8"
      "--keep-monthly 12"
    ];
    checkOpts = [ "--read-data-subset=2%" ];
    timerConfig = {
      OnCalendar = "03:30";
      Persistent = true;
      RandomizedDelaySec = "15m";
    };
  };

  systemd.services.restic-backups-hetzner.unitConfig.RequiresMountsFor = [ "/mnt/data/.snapshots" ];
}
