mkdir -p "$OUT"

q() {
  curl -sf --max-time 10 "$PROMETHEUS/api/v1/query" \
    --data-urlencode "query=$1" | jq -r '.data.result'
}

badge() {
  jq -n --arg l "$1" --arg m "$2" --arg c "$3" \
    '{schemaVersion:1,label:$l,message:$m,color:$c}' >"$OUT/$4.tmp"
  mv "$OUT/$4.tmp" "$OUT/$4"
}

home_re=$(printf '%s' "$HOME_DOMAIN" | sed 's/[.]/\\./g')

up=$(q 'sum(probe_success)' | jq -r '.[0].value[1] // "0"' | cut -d. -f1)
total=$(q 'count(probe_success)' | jq -r '.[0].value[1] // "0"' | cut -d. -f1)

color=red
if [ "$total" != "0" ] && [ "$up" = "$total" ]; then
  color=brightgreen
elif [ "$up" != "0" ]; then
  color=orange
fi
badge "services" "$up/$total up" "$color" "uptime.json"

q 'probe_success' |
  jq -r '.[] | "\(.metric.instance)\t\(.value[1])"' |
  while IFS=$'\t' read -r inst val; do
    name=$(printf '%s' "$inst" |
      sed -E "s#^https?://##; s#\.${home_re}/?\$##; s#[^A-Za-z0-9_-]#_#g")
    if [ "${val%%.*}" = "1" ]; then
      badge "$name" "up" "brightgreen" "svc_$name.json"
    else
      badge "$name" "down" "red" "svc_$name.json"
    fi
  done

# --- mesh reachability (measured from edge via iperf3) ---
donline=$(q 'sum(iperf3_up)' | jq -r '.[0].value[1] // "0"' | cut -d. -f1)
dtotal=$(q 'count(iperf3_up)' | jq -r '.[0].value[1] // "0"' | cut -d. -f1)

dcolor=red
if [ "$dtotal" != "0" ] && [ "$donline" = "$dtotal" ]; then
  dcolor=brightgreen
elif [ "$donline" != "0" ]; then
  dcolor=orange
fi
badge "devices" "$donline/$dtotal reachable" "$dcolor" "devices.json"

# edge itself: whether Prometheus (on nas) can scrape edge's pushgateway
edge_up=$(q 'up{job="iperf3"}' | jq -r '.[0].value[1] // "0"' | cut -d. -f1)
if [ "$edge_up" = "1" ]; then
  badge "edge" "online" "brightgreen" "edge.json"
else
  badge "edge" "offline" "red" "edge.json"
fi
