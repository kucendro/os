: "${PUSHGATEWAY:?}"

workflow=${1:?workflow}
status=${2:?status}
started=${3:-}
now=$(date +%s)
rev=$(git rev-parse HEAD 2>/dev/null || echo unknown)
if [ "$status" = success ]; then success=1; else success=0; fi

{
  echo "ci_run_success $success"
  echo "ci_run_timestamp_seconds $now"
  [ -z "$started" ] || echo "ci_run_duration_seconds $((now - started))"
  echo "ci_run_info{rev=\"$rev\"} 1"
} | curl -sSf --data-binary @- -X PUT "$PUSHGATEWAY/metrics/job/ci/workflow/$workflow" ||
  echo "push of ci/workflow/$workflow failed" >&2
