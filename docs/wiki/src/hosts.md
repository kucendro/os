<!-- Auto-generated from the Nix config by gen-wiki.py. Do not edit. -->

# Hosts

## 🖥️ edge

| | |
|---|---|
| Platform | `x86_64-linux` |
| State version | `25.11` |
| Users | kucendro |
| System packages | 156 |
| Open TCP ports | 22, 80, 443 |
| Open UDP ports | 3478 |
| Repo-configured services | 8 |

**Services** (configured in this repo):

- **fstrim** — `services/services.nix`
- **fwupd** — `services/services.nix`
- **headscale** — `services/mesh/headscale.nix`
- **iperf3** — `services/services.nix`
- **nginx** — `services/mesh/nginx.nix`
- **openssh** — `services/services.nix`
- **resolved** — `services/services.nix`
- **tailscale** — `services/mesh/tailscale.nix`

## 🖥️ nas

| | |
|---|---|
| Platform | `x86_64-linux` |
| State version | `25.11` |
| Users | kucendro |
| System packages | 171 |
| Open TCP ports | 22, 1704, 1705, 1780, 8095, 8097, 8927 |
| Open UDP ports | 5353 |
| Repo-configured services | 16 |

**Services** (configured in this repo):

- **actual** — `services/actual.nix`
- **fstrim** — `services/services.nix`
- **fwupd** — `services/services.nix`
- **gitea** — `services/gitea.nix`
- **grafana** — `services/grafana.nix`
- **immich** — `services/immich.nix`
- **iperf3** — `services/services.nix`
- **karakeep** — `services/karakeep.nix`
- **openssh** — `services/services.nix`
- **prometheus** — `services/monitoring/blackbox.nix`
- **resolved** — `services/services.nix`
- **rmfakecloud** — `services/remarkable.nix`
- **samba** — `services/share/server.nix`
- **tailscale** — `services/mesh/tailscale.nix`
- **usbmuxd** — `hosts/nas/tethering.nix`
- **vaultwarden** — `services/vault.nix`

## 🖥️ nixbook

| | |
|---|---|
| Platform | `x86_64-linux` |
| State version | `25.11` |
| Users | deploy, kucendro |
| System packages | 251 |
| Open TCP ports | 22, 443, 9901, 47984, 47989, 47990, 48010 |
| Open UDP ports | 1111, 2408, 5353, 6001, 6002, 9901, 47998, 47999, 48000, 48002, 48010, 57425, 57426 |
| Repo-configured services | 18 |

**Services** (configured in this repo):

- **avahi** — `profiles/laptop.nix`
- **fstrim** — `services/services.nix`
- **fwupd** — `services/services.nix`
- **greetd** — `profiles/laptop.nix`
- **gvfs** — `services/services.nix`
- **iperf3** — `services/services.nix`
- **irlume** — `hosts/nixbook/zenbook.nix`
- **monado** — `display/vr.nix`
- **openssh** — `services/services.nix`
- **passSecretService** — `services/services.nix`
- **pipewire** — `profiles/laptop.nix`
- **power-profiles-daemon** — `profiles/laptop.nix`
- **printing** — `services/services.nix`
- **resolved** — `services/services.nix`
- **sunshine** — `services/sunshine.nix`
- **tailscale** — `services/mesh/tailscale.nix`
- **udisks2** — `services/services.nix`
- **upower** — `profiles/laptop.nix`

## 🖥️ stockholm

| | |
|---|---|
| Platform | `x86_64-linux` |
| State version | `25.11` |
| Users | kucendro, ssm-user |
| System packages | 196 |
| Open TCP ports | 22, 47984, 47989, 47990, 48010 |
| Open UDP ports | 5353, 47998, 47999, 48000, 48002, 48010 |
| Repo-configured services | 8 |

**Services** (configured in this repo):

- **fstrim** — `services/services.nix`
- **greetd** — `profiles/workstation/session.nix`
- **iperf3** — `services/services.nix`
- **openssh** — `services/services.nix`
- **pipewire** — `profiles/workstation/session.nix`
- **resolved** — `services/services.nix`
- **sunshine** — `services/sunshine.nix`
- **tailscale** — `services/mesh/tailscale.nix`

## 🍏 mac

_nix-darwin host._

**LaunchDaemons:** activate-system, beszel-agent, caffeinate, iperf3-server, nix-daemon, sops-install-secrets

**User agents:** sunshine

**Homebrew casks:** tailscale-app
