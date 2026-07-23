<!-- Auto-generated from the Nix config by gen-wiki.py. Do not edit. -->

# Services

Every service this repo configures, the host(s) that run it, and the file that defines it.

| Service | Hosts | Defined in |
|---|---|---|
| **avahi** | nixbook | `targets/nixbook/default.nix` |
| **fstrim** | edge, nas, nixbook | `services/services.nix` |
| **fwupd** | edge, nas, nixbook | `services/services.nix` |
| **gitea** | nas | `services/gitea.nix` |
| **grafana** | nas | `services/grafana.nix` |
| **greetd** | nixbook | `targets/nixbook/default.nix` |
| **gvfs** | nixbook | `services/services.nix` |
| **headscale** | edge | `services/mesh/headscale.nix` |
| **immich** | nas | `services/immich.nix` |
| **iperf3** | edge, nas, nixbook | `services/services.nix` |
| **nginx** | edge | `services/mesh/nginx.nix` |
| **openssh** | edge, nas, nixbook | `services/services.nix` |
| **passSecretService** | nixbook | `services/services.nix` |
| **pipewire** | nixbook | `targets/nixbook/default.nix` |
| **power-profiles-daemon** | nixbook | `targets/nixbook/default.nix` |
| **printing** | nixbook | `services/services.nix` |
| **prometheus** | nas | `services/monitoring/blackbox.nix` |
| **resolved** | edge, nas, nixbook | `services/services.nix` |
| **samba** | nas | `services/share/server.nix` |
| **sunshine** | nixbook | `services/sunshine.nix` |
| **tailscale** | edge, nas, nixbook | `services/mesh/tailscale.nix` |
| **udisks2** | nixbook | `services/services.nix` |
| **upower** | nixbook | `targets/nixbook/default.nix` |
| **usbmuxd** | nas | `targets/nas/tethering.nix` |
| **vaultwarden** | nas | `services/vault.nix` |
