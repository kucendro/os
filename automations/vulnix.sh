export LC_ALL=C

host=${1:?host}
closure=${2:?closure}
state=${XDG_STATE_HOME:-$HOME/.local/state}/vulnix
seen=$state/$host.tsv

mkdir -p "$state"
rows=$(mktemp "$state/.$host.XXXXXX")
trap 'rm -f "$rows"' EXIT

rc=0
report=$(vulnix --closure --json "$closure") || rc=$?
# 2 means advisories found, but vulnix also exits 2 on internal errors
if [ "$rc" -ne 0 ] && [ "$rc" -ne 2 ]; then
  echo "vulnix exited $rc on $closure" >&2
  exit 1
fi
if ! jq -e 'type == "array"' >/dev/null <<<"$report"; then
  echo "vulnix printed no report for $closure" >&2
  exit 1
fi

jq -r '.[] | . as $d | .affected_by[] | [($d.cvssv3_basescore[.] // "-"), $d.pname, $d.version, .] | @tsv' <<<"$report" |
  sort -t $'\t' -u -k1,1gr -k2 >"$rows"

total=$(wc -l <"$rows")
packages=$(cut -f2 "$rows" | sort -u | wc -l)
echo "$host: $total advisories in $packages packages" >&2
tr '\t' ' ' <"$rows" >&2

if [ ! -f "$seen" ]; then
  echo "vulnix $host baseline: $total advisories in $packages packages, only new ones get reported from now on"
else
  fresh=$(awk -F '\t' 'FILENAME == ARGV[1] { seen[$2 FS $4]; next } !(($2 FS $4) in seen)' "$seen" "$rows")
  if [ -n "$fresh" ]; then
    count=$(wc -l <<<"$fresh")
    echo "vulnix $host: $count new advisories"
    head -n 25 <<<"$fresh" | tr '\t' ' '
    if [ "$count" -gt 25 ]; then
      echo "and $((count - 25)) more in the run log"
    fi
  fi
fi

mv "$rows" "$seen"
