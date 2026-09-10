: "${PHONE_NAME:?}" "${SSH_CONFIG:?}" "${REACHES:?}" "${DEFAULT_REMOTE:?}" "${WIKI_URL:?}"

PHONE_URL="$WIKI_URL/blink/$PHONE_NAME"
THEME_URL="$WIKI_URL/phone"

#
# snips are the menu on ios: cmd+< then type the host name
#
read -ra remotes <<<"$REACHES"
# shellcheck disable=SC2088 # expands on the phone, not here
SNIPS='~/Documents/snips/peer'
snip() { printf 'mosh %s -- tmux new -A -s %s\n' "$1" "$PHONE_NAME"; }

#
# bootstrap one-liner, pasted into blink's own shell
#
cmds=("mkdir -p ~/.ssh $SNIPS" "curl -fsSL $PHONE_URL/config -o ~/.ssh/config")
for r in "${remotes[@]}"; do
  cmds+=("curl -fsSL $PHONE_URL/snips/peer/$r.sh -o $SNIPS/$r.sh")
done
BOOTSTRAP=$(
  IFS=';'
  printf '%s' "${cmds[*]}"
)
BOOTSTRAP=${BOOTSTRAP//;/; }

#
# setup cheat
#

case "${1:-}" in
--qr)
  printf '%s' "$BOOTSTRAP" | qrencode -t ANSIUTF8 -l L
  printf '\nScan & paste into Blink (%d-char payload).\n' "${#BOOTSTRAP}" >&2
  ;;
--png)
  printf '%s' "$BOOTSTRAP" | qrencode -o "${2:?--png needs an output path SON}" -s 6 -l L
  ;;
--bundle)
  dir=${2:?--bundle needs an output dir SON}
  mkdir -p "$dir/snips/peer"
  printf '%s' "$SSH_CONFIG" >"$dir/config"
  printf '%s\n' "$BOOTSTRAP" >"$dir/bootstrap.txt"
  for r in "${remotes[@]}"; do
    snip "$r" >"$dir/snips/peer/$r.sh"
  done
  ;;
--md)
  cat <<EOF
## ${PHONE_NAME}

![${PHONE_NAME}](blink/${PHONE_NAME}.png)

1. Settings, Keys, +, ed25519 named \`id_ed25519\`, copy the public key into the repo
2. Settings, Appearance, New Theme: \`${THEME_URL}/carbonfox.js\`, New Font: \`${THEME_URL}/font.css\`
3. Paste into Blink's shell (or scan the code):

   \`\`\`
   ${BOOTSTRAP}
   \`\`\`

4. cmd+< opens the snips, type a host (default ${DEFAULT_REMOTE}), enter

EOF
  ;;
*)
  printf '%s\n' "$BOOTSTRAP"
  ;;
esac
