<!-- Auto-generated from the Nix config by gen-wiki.py. Do not edit. -->

# Services

Every service this repo configures, the host(s) that run it, and the file that defines it.

| Service | Hosts | Defined in |
|---|---|---|
| **actual** | nas | `services/actual.nix` |
| **avahi** | nixbook | `profiles/laptop.nix` |
| **fstrim** | edge, nas, nixbook, stockholm | `services/services.nix` |
| **fwupd** | edge, nas, nixbook | `services/services.nix` |
| **gitea** | nas | `services/gitea.nix` |
| **grafana** | nas | `services/grafana.nix` |
| **greetd** | nixbook, stockholm | `profiles/laptop.nix` `profiles/workstation/session.nix` |
| **gvfs** | nixbook | `services/services.nix` |
| **headscale** | edge | `services/mesh/headscale.nix` |
| **immich** | nas | `services/immich.nix` |
| **iperf3** | edge, nas, nixbook, stockholm | `services/services.nix` |
| **irlume** | nixbook | `hosts/nixbook/zenbook.nix` |
| **karakeep** | nas | `services/karakeep.nix` |
| **monado** | nixbook | `display/vr.nix` |
| **nginx** | edge | `services/mesh/nginx.nix` |
| **openssh** | edge, nas, nixbook, stockholm | `services/services.nix` |
| **passSecretService** | nixbook | `services/services.nix` |
| **pipewire** | nixbook, stockholm | `profiles/laptop.nix` `profiles/workstation/session.nix` |
| **power-profiles-daemon** | nixbook | `profiles/laptop.nix` |
| **printing** | nixbook | `services/services.nix` |
| **prometheus** | nas | `services/monitoring/blackbox.nix` |
| **resolved** | edge, nas, nixbook, stockholm | `services/services.nix` |
| **samba** | nas | `services/share/server.nix` |
| **sunshine** | nixbook, stockholm | `services/sunshine.nix` |
| **tailscale** | edge, nas, nixbook, stockholm | `services/mesh/tailscale.nix` |
| **udisks2** | nixbook | `services/services.nix` |
| **upower** | nixbook | `profiles/laptop.nix` |
| **usbmuxd** | nas | `hosts/nas/tethering.nix` |
| **vaultwarden** | nas | `services/vault.nix` |
