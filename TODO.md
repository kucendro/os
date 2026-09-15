# TODO

Candidate services for nas, ranked by impact. All have a NixOS module in the pinned nixpkgs.

## High

- [x] Snapshots: btrbk hourly into `/mnt/data/.snapshots`, all kept 2 days, then 14 dailies and 8 weeklies (`services/backup/snapshots.nix`, 2026-09-14).
- [x] Offsite: restic over SFTP to the Hetzner Storage Box, nightly 03:30 from its own read-only snapshot, plus nightly `pg_dumpall` and the vaultwarden backup dir. Excludes docker and immich thumbs and encoded video. Heartbeat to the edge pushgateway, Grafana rule `Backups stale` to Telegram, `OnFailure` Telegram with journal lines (`services/backup/`, 2026-09-15).
- [ ] Offsite rollout: deploy nas, first run by hand, then daily snapshots on the box in the Hetzner console. Second local disk later: btrbk `target` on it, same instance.
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
- [ ] Plain exit node on edge first, no Mullvad yet. New `services/mesh/exit-node.nix` mirroring `subnet-router.nix` (`useRoutingFeatures = "server"`, `--advertise-exit-node`), import in `hosts/edge/default.nix`, in `acl.json` add `autoApprovers.exitNode` and `autogroup:internet` for admins. Covers foreign WiFi, websites see the Hetzner IP. Cost measured from nixbook 2026-09-14: edge RTT 18 ms vs 6 ms direct, so about 12 ms added; throughput capped by the edge iperf3 numbers in Grafana.
- [ ] Mullvad key for edge behind that exit node, only if the VPS IP should stay hidden: policy rule `iif tailscale0` into the tunnel, edge's own default route untouched, DNS and IPv6 through the tunnel too. Deploy from home with plain SSH reachable.
- [ ] Mullvad has no port forwarding, so not connectable. If torrents matter more than the exit node, use AirVPN or Proton instead.

## Hygiene

- [ ] Vaultwarden: disable signups, accounts exist.
- [ ] remarkable (rmfakecloud): commented out on nas and in endpoints, finish or remove `services/remarkable.nix`.
