# TODO

## Move CI builds off nas to a builder workstation (waiting on hardware)

The weekly `update.yaml` job (flake update, check, build nas/edge/nixbook closures)
runs on the nas runner. Too heavy: NUC-class box, 30s hardware watchdog
(`hosts/nas/reliability.nix`), ~20 services. Move it to a dedicated always-on
workstation once the hardware exists.

When the hardware arrives:

1. New host in `flake.nix` (e.g. `forge`) with `profile = "workstation"` and
   `hosts/forge/` (hw-config + disko). `profiles/workstation/` is shared with
   stockholm; `gpu.nix` assumes nvidia, split it out if the new box differs.
   `session.nix` already disables suspend, which suits a builder.
2. Split the runner out of `services/gitea.nix` into `services/gitea-runner.nix`
   (instance name from hostname). nas keeps label `native:host`, the builder
   registers `builder:host`.
3. Secrets repo, by hand: declare the `gitea-runner-env` template and
   `gitea-deploy-key` for the new host, and add `gitea-deploy-pubkey` to the
   `nas-authorized-keys` template so the builder can push closures to nas as a
   trusted user.
4. `update.yaml`: `runs-on: builder`; after building, `nix copy --to
   ssh-ng://kucendro@nas` each closure and create gcroots on nas (harmonia
   serves nas's /nix/store, so results must land there). Commit step unchanged
   (same deploy key identity).
5. Optionally move `check.yaml` (PR `nix flake check`) to `runs-on: builder` too.

Until then builds stay on nas. If the watchdog ever bites during a build,
interim mitigation: systemd resource limits on `gitea-runner-nas`
(CPUQuota/MemoryHigh) plus low `--max-jobs`.
