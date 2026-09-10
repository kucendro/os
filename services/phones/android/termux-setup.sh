: "${PHONE_NAME:?}" "${ME_NAME:?}" "${SSH_CONFIG:?}" "${REACHES:?}"
: "${DEFAULT_REMOTE:?}" "${WIKI_URL:?}" "${MENU_FILE:?}"

#
# keyboard fixes
#

EXTRA_KEYS="extra-keys = [['ESC','/','-','HOME','UP','END'],['TAB','CTRL','ALT','LEFT','DOWN','RIGHT']]"

#
# peer menu, shown on every new local shell
#

MENU=$(cat "$MENU_FILE")

OUT=$(
  cat <<EOF
#!/data/data/com.termux/files/usr/bin/bash
set -e

pkg upgrade -y
pkg install -y openssh mosh tmux curl

[ -d ~/storage ] || termux-setup-storage
mkdir -p ~/.ssh ~/.termux

cat > ~/.ssh/config <<'CONFIG_EOF'
${SSH_CONFIG}CONFIG_EOF
chmod 600 ~/.ssh/config

[ -f ~/.ssh/id_ed25519 ] || ssh-keygen -t ed25519 -N "" -C "${ME_NAME}@${PHONE_NAME}" -f ~/.ssh/id_ed25519

cat > ~/.termux/termux.properties <<'PROPS_EOF'
${EXTRA_KEYS}
fullscreen = true
PROPS_EOF

curl -fsSL '${WIKI_URL}/phone/colors.properties' -o ~/.termux/colors.properties
curl -fsSL '${WIKI_URL}/phone/font.ttf' -o ~/.termux/font.ttf

touch ~/.hushlogin
mkdir -p ~/.local/bin
cat > ~/.local/bin/peer <<'PEER_EOF'
#!/data/data/com.termux/files/usr/bin/bash
export PEER_REMOTES='${REACHES}' PEER_DEFAULT='${DEFAULT_REMOTE}' PEER_SESSION='${PHONE_NAME}'
${MENU}
PEER_EOF
chmod +x ~/.local/bin/peer

grep -q 'local/bin/peer' ~/.bashrc 2>/dev/null || cat >> ~/.bashrc <<'BASHRC_EOF'
export PATH=\$HOME/.local/bin:\$PATH
[[ \$- == *i* && -z \$TMUX && -z \$SSH_CONNECTION ]] && peer
BASHRC_EOF

termux-reload-settings

echo
echo "------------------------------------"
echo "${PHONE_NAME} LINKED SON"
echo "------------------------------------"

cat ~/.ssh/id_ed25519.pub
EOF
)

#
# setup cheat
#

case "${1:-}" in
--qr | --png)
  payload=$(printf '%s\n' "$OUT" | gzip -9 | base64 | tr -d '\n')
  oneliner="echo $payload|base64 -d|gzip -d|bash"

  if [ "$1" = "--qr" ]; then
    printf '%s' "$oneliner" | qrencode -t ANSIUTF8 -l L
    printf '\nScan & paste into Termux (%d-char payload).\n' "${#oneliner}" >&2
  else
    printf '%s' "$oneliner" | qrencode -o "${2:?--png needs an output path SON}" -s 6 -l L
  fi
  ;;
*)
  printf '%s\n' "$OUT"
  ;;
esac
