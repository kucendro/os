: "${PEER_REMOTES:?}" "${PEER_DEFAULT:?}" "${PEER_SESSION:?}"

read -ra remotes <<<"$PEER_REMOTES"

n=${#remotes[@]}
cur=0

for i in "${!remotes[@]}"; do
  [ "${remotes[$i]}" = "$PEER_DEFAULT" ] && cur=$i
done

msg=""

UP=$'\e[A' DOWN=$'\e[B' ESC=$'\e'

trap 'printf "\e[?25h"' EXIT

draw() {
  printf '\e[H\e[J\n  peer\n\n'
  for i in "${!remotes[@]}"; do
    star=" "
    [ "${remotes[$i]}" = "$PEER_DEFAULT" ] && star="*"
    if [ "$i" -eq "$cur" ]; then
      printf '  \e[7m %s %-16s \e[0m\n' "$star" "${remotes[$i]}"
    else
      printf '    %s %-16s\n' "$star" "${remotes[$i]}"
    fi
  done
  printf '\n  j/k or arrows move   enter connect   l local\n'
  [ -n "$msg" ] && printf '\n  %s\n' "$msg"
}

connect() {
  printf '\e[?25h\e[H\e[J\n  %s ...\n' "$1"
  if ssh -o ConnectTimeout=3 -o BatchMode=yes "$1" true 2>/dev/null; then
    exec mosh "$1" -- tmux new -A -s "$PEER_SESSION"
  fi
  msg="$1 unreachable"
  printf '\e[?25l'
}

printf '\e[?25l'
while :; do
  draw
  IFS= read -rsn1 key
  if [ "$key" = "$ESC" ]; then
    IFS= read -rsn2 -t 0.05 rest && key+=$rest
  fi
  case $key in
  "$UP" | k) cur=$(((cur - 1 + n) % n)) ;;
  "$DOWN" | j) cur=$(((cur + 1) % n)) ;;
  [1-9]) [ "$key" -le "$n" ] && {
    cur=$((key - 1))
    connect "${remotes[$cur]}"
  } ;;
  "") connect "${remotes[$cur]}" ;;
  l | q | "$ESC") break ;;
  esac
done
printf '\e[H\e[J'
