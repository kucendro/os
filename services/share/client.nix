{ config, pkgs, ... }:

{
  fileSystems."/mnt/nas" = {
    device = "//nas.ts.kucendro.dev/data";
    fsType = "cifs";
    options = [
      "credentials=${config.sops.templates."smb-creds".path}"
      "_netdev"
      "x-systemd.after=tailscaled.service"
      "x-systemd.requires=tailscaled.service"
      "x-systemd.mount-timeout=90"
      "nofail"
      "uid=1000"
      "gid=100"
      "iocharset=utf8"
    ];
  };

  environment.systemPackages = [ pkgs.cifs-utils ];
}
