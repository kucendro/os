# SMB share (TODO)

Mount the NAS data pool as a network drive on the nixbook (file-explorer access),
tailnet-only. ~40 lines total + 1 sops secret + 1 one-time command.

## NAS — `services/share.nix` (import in `targets/nas/default.nix`)

```nix
services.samba = {
  enable = true;
  openFirewall = false;                       # scoped to tailscale0 below
  settings = {
    global = {
      "bind interfaces only" = "yes";
      "interfaces" = "lo tailscale0";
      "hosts allow" = "100.64.0.0/10 127.0.0.1";
    };
    data = {
      path = "/mnt/data";                     # or /mnt/data/share
      "read only" = "no";
      "valid users" = "kucendro";
      "force user" = "kucendro";
    };
  };
};
networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ 139 445 ];
```

## nixbook — automount

```nix
fileSystems."/mnt/nas" = {
  device = "//nas.ts.kucendro.dev/data";
  fsType = "cifs";
  options = [
    "credentials=${config.sops.secrets.smb-creds.path}"
    "x-systemd.automount" "noauto" "nofail"
    "uid=1000" "gid=100" "iocharset=utf8"
  ];
};
environment.systemPackages = [ pkgs.cifs-utils ];
```

## One-time bits

- sops secret `smb-creds` with `username=kucendro` / `password=…` (CIFS creds file format).
- On NAS: `smbpasswd -a kucendro` (Samba has its own password DB) — or wire declaratively.

## Notes

- Decide scope: whole `/mnt/data` vs dedicated `/mnt/data/share`.
- Tailnet-only (bound to `tailscale0`), same posture as Immich/Vaultwarden.
- Linux-only alternative: NFS (leaner/faster, but no cross-platform/file-explorer niceties).
- Not a backup or a cloud — for sync/mobile/external sharing, that's Nextcloud (heavier; Immich already covers photos).
```
