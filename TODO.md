# TODO

Candidate services for nas, ranked by impact. All have a NixOS module in the pinned nixpkgs.

## High

- [ ] Backups: btrbk hourly snapshots into `/mnt/data/.snapshots` (currently empty) and `services.restic.backups` offsite (Hetzner Storage Box, Backblaze B2, or kDrive via rclone). Pre-hook `pg_dump` for immich, set vaultwarden `backupDir`. Covers immich, vaultwarden, gitea, karakeep, home-assistant.
- [ ] Paperless-ngx: scanned and mailed documents with OCR and search. Pairs with the printer, reMarkable and karakeep.
- [ ] Glance start page: one page for all `*@home` vhosts, config generated from `services/mesh/proxied/endpoints.nix`. Widgets for immich, gitea, grafana, syncthing, RSS.
- [ ] Home Assistant voice: `services.wyoming.faster-whisper` and `services.wyoming.piper` on nas, HA Ollama integration pointed at stockholm for the Assist pipeline.

## Medium

- [ ] Miniflux: RSS reader, keepers go to karakeep, feed shown in Glance.
- [ ] ntfy: curl-able push. Grafana contact point, HA notify target, systemd `OnFailure` for lazybaka and restic timers. Optional, telegram already works.
- [ ] Jellyfin or Navidrome plus Audiobookshelf: only with a local library. Both are Music Assistant providers, so party and ledfx play local files.
- [ ] SSO with Pocket ID: passkey OIDC for immich, gitea, grafana, karakeep, open-webui, vaultwarden. Convenience only, tailnet already gates access.

## Low

- [ ] Mealie: recipes and meal planning, HA integration.
- [ ] Mosquitto: needed by the frigate HA integration once cameras exist.
- [ ] comin: nas pulls from gitea and rebuilds itself instead of manual deploy.

## Torrents

- [ ] Mullvad WireGuard key for nas in sops, tunnel in its own network namespace, qBittorrent the only service inside (kill switch by construction). Web UI via veth as `torrent@home`, category `audiobooks` saves to `/mnt/data/audiobooks` for Audiobookshelf. Prowlarr for indexer search. Private trackers, ratio cap. Do not route through edge.
- [ ] Mullvad key for edge as tailnet exit node: policy rule `iif tailscale0` into the tunnel, edge's own default route untouched. Deploy from home with plain SSH reachable.
- [ ] Mullvad has no port forwarding, so not connectable. If torrents matter more than the exit node, use AirVPN or Proton instead.

## Hygiene

- [ ] Vaultwarden: disable signups, accounts exist.
- [ ] remarkable (rmfakecloud): commented out on nas and in endpoints, finish or remove `services/remarkable.nix`.
