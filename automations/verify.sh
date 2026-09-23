: "${PUSHGATEWAY:?}"

flake=${FLAKE:-.}
read -ra ssh_opts <<<"${SSH_OPTS:-}"
self=$(cat /proc/sys/kernel/hostname 2>/dev/null || true)

nix() { command nix --extra-experimental-features "nix-command flakes" "$@"; }

push() {
  curl -sSf --data-binary @- -X PUT "$PUSHGATEWAY/metrics/job/$1" ||
    echo "push of $1 failed" >&2
}

#
# ci run outcome, called from the workflow's last step
#

if [ "${1:-}" = run ]; then
  workflow=${2:?workflow}
  status=${3:?status}
  started=${4:-}
  now=$(date +%s)
  rev=$(git rev-parse --short HEAD 2>/dev/null || echo unknown)
  if [ "$status" = success ]; then success=1; else success=0; fi
  {
    echo "ci_run_success $success"
    echo "ci_run_timestamp_seconds $now"
    [ -z "$started" ] || echo "ci_run_duration_seconds $((now - started))"
    echo "ci_run_info{rev=\"$rev\"} 1"
  } | push "ci/workflow/$workflow"
  exit 0
fi

#
# which system a node runs and whether it booted it, asked over ssh
# or locally when the node is the runner's own host
#

probe() {
  if [ "$1" = "$self" ]; then
    bash -s
  else
    ssh "${ssh_opts[@]}" -o BatchMode=yes -o ConnectTimeout=5 "$2@$3" bash -s
  fi <<'REMOTE'
readlink -f /run/current-system
for f in kernel initrd kernel-modules; do
  [ "$(readlink -f /run/booted-system/$f)" = "$(readlink -f /run/current-system/$f)" ] || { echo reboot; break; }
done
REMOTE
}

verify_node() {
  local node=$1 host user expected out current ok reboot closure
  host=$(jq -r ".\"$node\".hostname" <<<"$nodes")
  user=$(jq -r ".\"$node\".sshUser" <<<"$nodes")
  expected=$(jq -r ".\"$node\"" <<<"$systems")

  if ! out=$(probe "$node" "$user" "$host"); then
    echo "$node unreachable, skipping"
    return 0
  fi

  current=$(sed -n 1p <<<"$out")
  if [ "$current" = "$expected" ]; then ok=1; else ok=0; fi
  if grep -qx reboot <<<"$out"; then reboot=1; else reboot=0; fi
  closure=$(nix path-info -S --json "$expected" 2>/dev/null | jq -r '.[] | .closureSize? | numbers' | head -1 || true)

  {
    echo "verify_timestamp_seconds $(date +%s)"
    echo "verify_current $ok"
    echo "verify_reboot_needed $reboot"
    [ -z "$closure" ] || echo "verify_closure_bytes $closure"
  } | push "verify/node/$node"

  echo "$node: current=$ok reboot=$reboot closure=${closure:-?}"
}

nodes=$(nix eval --json "$flake#deploy.nodes" \
  --apply 'ns: builtins.mapAttrs (_: n: { inherit (n) hostname sshUser; }) ns')
systems=$(nix eval --json "$flake#nixosConfigurations" \
  --apply 'cfgs: builtins.mapAttrs (_: c: c.config.system.build.toplevel.outPath) cfgs')

if [ $# -gt 0 ]; then
  selected=("$@")
else
  mapfile -t selected < <(jq -r 'keys[]' <<<"$nodes")
fi

for node in "${selected[@]}"; do
  verify_node "$node"
done
