#
# push the workstation image to GHCR and manage the RunPod pod
#
# entry: nix run .#runpod -- <command>
#
# commands:
#   push            build .#workstation and copy it to $IMAGE:$TAG on GHCR
#   up              create a new pod from the image (injects TS_AUTHKEY)
#   start <podId>   resume a stopped pod
#   stop  <podId>   stop a running pod (keeps the volume; this is scale-to-zero)
#   rm    <podId>   terminate a pod
#   ls              list pods
#
# auth prerequisites:
#   push : skopeo login ghcr.io -u $GHCR_USER   (once, with a write:packages PAT)
#   up   : RUNPOD_API_KEY set (or run `runpodctl config --apiKey <key>` once)
#          TS_AUTHKEY set (a headscale/tailscale pre-auth key)
#
# private image note: runpodctl cannot attach registry credentials. for a
# private GHCR package, create a RunPod template in the console carrying the
# image + its GHCR credential and pass its id as TEMPLATE_ID; the pod pulls
# privately and TS_AUTHKEY is still injected via --env. a public package needs
# only IMAGE.
#
# tunables (all env, shown with defaults):
#   IMAGE=ghcr.io/$GHCR_USER/workstation  TAG=latest  POD_NAME=workstation
#   GPU_TYPE="NVIDIA GeForce RTX 4090"    GPU_COUNT=1
#   CONTAINER_DISK=30  VOLUME_SIZE=50  VOLUME_PATH=/workspace
#   NETWORK_VOLUME_ID=  (persistent volume from the console; overrides VOLUME_SIZE)
#   TEMPLATE_ID=  CLOUD_FLAG=--secureCloud  COST_CEILING=  DATACENTER_ID=
#   TS_LOGIN_SERVER=  TS_HOSTNAME=  FLAKE=.
#

cmd="${1:-}"
if [ "$#" -gt 0 ]; then shift; fi

flake="${FLAKE:-.}"
ghcr_user="${GHCR_USER:-}"
image="${IMAGE:-ghcr.io/${ghcr_user}/workstation}"
tag="${TAG:-latest}"

pod_name="${POD_NAME:-workstation}"
gpu_type="${GPU_TYPE:-NVIDIA GeForce RTX 4090}"
gpu_count="${GPU_COUNT:-1}"
container_disk="${CONTAINER_DISK:-30}"
volume_path="${VOLUME_PATH:-/workspace}"
volume_size="${VOLUME_SIZE:-50}"
network_volume_id="${NETWORK_VOLUME_ID:-}"
template_id="${TEMPLATE_ID:-}"
cloud_flag="${CLOUD_FLAG:---secureCloud}"
cost_ceiling="${COST_CEILING:-}"
datacenter_id="${DATACENTER_ID:-}"

configure_api() {
  if [ -n "${RUNPOD_API_KEY:-}" ]; then
    runpodctl config --apiKey "$RUNPOD_API_KEY" >/dev/null
  fi
}

case "$cmd" in
push)
  : "${ghcr_user:?set GHCR_USER (or IMAGE)}"
  out=$(nix build "${flake}#workstation" --no-link --print-out-paths)
  tmp=$(mktemp --suffix=.tar)
  trap 'rm -f "$tmp"' EXIT
  gzip -dc "$out" >"$tmp"
  skopeo copy "docker-archive:$tmp" "docker://${image}:${tag}"
  echo "pushed ${image}:${tag}"
  ;;

up)
  : "${TS_AUTHKEY:?set TS_AUTHKEY (a tailscale/headscale pre-auth key)}"
  configure_api
  args=(create pod
    --name "$pod_name"
    --gpuType "$gpu_type"
    --gpuCount "$gpu_count"
    --containerDiskSize "$container_disk"
    --volumePath "$volume_path"
    --env "TS_AUTHKEY=$TS_AUTHKEY"
  )
  if [ -n "${TS_LOGIN_SERVER:-}" ]; then
    args+=(--env "TS_LOGIN_SERVER=$TS_LOGIN_SERVER")
  fi
  if [ -n "${TS_HOSTNAME:-}" ]; then
    args+=(--env "TS_HOSTNAME=$TS_HOSTNAME")
  fi
  if [ -n "$network_volume_id" ]; then
    args+=(--networkVolumeId "$network_volume_id")
  else
    args+=(--volumeSize "$volume_size")
  fi
  if [ -n "$cloud_flag" ]; then
    args+=("$cloud_flag")
  fi
  if [ -n "$cost_ceiling" ]; then
    args+=(--cost "$cost_ceiling")
  fi
  if [ -n "$datacenter_id" ]; then
    args+=(--dataCenterId "$datacenter_id")
  fi
  if [ -n "$template_id" ]; then
    args+=(--templateId "$template_id")
  else
    args+=(--imageName "${image}:${tag}")
  fi
  runpodctl "${args[@]}"
  ;;

start)
  : "${1:?usage: start <podId>}"
  configure_api
  runpodctl start pod "$1"
  ;;

stop)
  : "${1:?usage: stop <podId>}"
  configure_api
  runpodctl stop pod "$1"
  ;;

rm)
  : "${1:?usage: rm <podId>}"
  configure_api
  runpodctl remove pod "$1"
  ;;

ls)
  configure_api
  runpodctl get pod
  ;;

*)
  echo "usage: nix run .#runpod -- {push|up|start <id>|stop <id>|rm <id>|ls}" >&2
  exit 2
  ;;
esac
