: "${PHONE_NAME:?}" "${ME_NAME:?}" "${DOMAIN:?}" "${REACHES:?}"
: "${DEFAULT_REMOTE:?}" "${THEME_FILE:?}" "${FONT_URL:?}"

SSH_CONFIG=""
for h in $REACHES; do
  SSH_CONFIG="${SSH_CONFIG}Host ${h}
  HostName ${h}.${DOMAIN}
  User ${ME_NAME}
  Port 22
  IdentityFile ~/.ssh/id_ed25519
"
done

get() { sed -n "s/^[[:space:]]*$1:[[:space:]]*\"\\(#[0-9a-fA-F]\\{6\\}\\)\".*/\\1/p" "$THEME_FILE"; }
b00=$(get base00)
b03=$(get base03)
b05=$(get base05)
b07=$(get base07)
b08=$(get base08)
b0A=$(get base0A)
b0B=$(get base0B)
b0C=$(get base0C)
b0D=$(get base0D)
b0E=$(get base0E)
COLORS="background=${b00}
foreground=${b05}
cursor=${b05}
color0=${b00}
color1=${b08}
color2=${b0B}
color3=${b0A}
color4=${b0D}
color5=${b0E}
color6=${b0C}
color7=${b05}
color8=${b03}
color9=${b08}
color10=${b0B}
color11=${b0A}
color12=${b0D}
color13=${b0E}
color14=${b0C}
color15=${b07}"

EXTRA_KEYS="extra-keys = [['ESC','/','-','HOME','UP','END'],['TAB','CTRL','ALT','LEFT','DOWN','RIGHT']]"

AUTO_CONNECT=$(
  cat <<AC_EOF
if [[ \$- == *i* && -z \$TMUX && -z \$SSH_CONNECTION ]]; then
  if ssh -o ConnectTimeout=3 -o BatchMode=yes ${DEFAULT_REMOTE} true 2>/dev/null; then
    exec mosh ${DEFAULT_REMOTE} -- tmux new-session -A -s main
  else
    exec tmux new-session -A -s local
  fi
fi
AC_EOF
)

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

# Keep an existing key (its pubkey is fold-pubkey in sops); only mint if absent.
[ -f ~/.ssh/id_ed25519 ] || ssh-keygen -t ed25519 -N "" -C "${ME_NAME}@${PHONE_NAME}" -f ~/.ssh/id_ed25519

cat > ~/.termux/colors.properties <<'COLORS_EOF'
${COLORS}
COLORS_EOF

cat > ~/.termux/termux.properties <<'PROPS_EOF'
${EXTRA_KEYS}
fullscreen = true
PROPS_EOF

[ -f ~/.termux/font.ttf ] || curl -fsSL '${FONT_URL}' -o ~/.termux/font.ttf

cat >> ~/.bashrc <<'BASHRC_EOF'
${AUTO_CONNECT}
BASHRC_EOF

termux-reload-settings

echo
echo "Termux linked. Open it and you land in tmux session 'main' on ${DEFAULT_REMOTE} via mosh."
echo "If ${DEFAULT_REMOTE} is asleep or offline, you get a plain local tmux instead."
echo "Nothing runs in the background on the phone. No sshd, no boot scripts, no battery whitelisting needed."
echo "Phone public key — this must match fold-pubkey in sops (else update sops + redeploy hosts):"
cat ~/.ssh/id_ed25519.pub
EOF
)

case "${1:-}" in
--qr | --png)
  payload=$(printf '%s\n' "$OUT" | gzip -9 | base64 | tr -d '\n')
  oneliner="echo $payload|base64 -d|gzip -d|bash"
  if [ "$1" = "--qr" ]; then
    printf '%s' "$oneliner" | qrencode -t ANSIUTF8 -l L
    printf '\nScan → paste into Termux → Enter (%d-char payload).\n' "${#oneliner}" >&2
    printf 'It is a dense QR; shrink the terminal font so the whole code fits on screen.\n' >&2
  else
    printf '%s' "$oneliner" | qrencode -o "${2:?--png needs an output path}" -s 6 -l L
  fi
  ;;
*)
  printf '%s\n' "$OUT"
  ;;
esac
