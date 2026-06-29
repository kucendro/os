: "${PHONE_NAME:?}" "${ME_NAME:?}" "${DOMAIN:?}" "${REACHES:?}"
: "${TRUSTED_PUBKEY_NAMES:?}" "${SECRETS_FILE:?}" "${THEME_FILE:?}" "${FONT_URL:?}"

AUTH_KEYS=""
for k in $TRUSTED_PUBKEY_NAMES; do
  v=$(sops decrypt --extract "[\"$k\"]" "$SECRETS_FILE") ||
    {
      echo "termux-setup: sops could not decrypt '$k' from $SECRETS_FILE" >&2
      exit 1
    }
  AUTH_KEYS="${AUTH_KEYS}${v}"$'\n'
done

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

OUT=$(cat <<EOF
#!/data/data/com.termux/files/usr/bin/bash
set -e

pkg update -y
pkg install -y openssh mosh curl

[ -d ~/storage ] || termux-setup-storage
mkdir -p ~/.ssh ~/.termux ~/.termux/boot

cat > ~/.ssh/authorized_keys <<'KEYS_EOF'
${AUTH_KEYS}KEYS_EOF
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys

cat > ~/.ssh/config <<'CONFIG_EOF'
${SSH_CONFIG}CONFIG_EOF
chmod 600 ~/.ssh/config

# Keep an existing key (its pubkey is fold-pubkey in sops); only mint if absent.
[ -f ~/.ssh/id_ed25519 ] || ssh-keygen -t ed25519 -N "" -C "${ME_NAME}@${PHONE_NAME}" -f ~/.ssh/id_ed25519

cat > ~/.termux/colors.properties <<'COLORS_EOF'
${COLORS}
COLORS_EOF

[ -f ~/.termux/font.ttf ] || curl -fsSL '${FONT_URL}' -o ~/.termux/font.ttf

cat > ~/.termux/boot/start-sshd <<'BOOT_EOF'
#!/data/data/com.termux/files/usr/bin/sh
termux-wake-lock
sshd
BOOT_EOF
chmod +x ~/.termux/boot/start-sshd

# Hold a wakelock now so Android doesn't suspend Termux (and drop sshd) on lock.
termux-wake-lock
if [ -n "\${SSH_CONNECTION:-}" ]; then
  echo "Running over SSH — leaving sshd up."
else
  pkill sshd 2>/dev/null || true
  sshd
fi
termux-reload-settings

echo
echo "Termux linked: sshd on :8022, carbonfox + Hack Nerd Font applied."
echo "Phone public key — this must match fold-pubkey in sops (else update sops + redeploy hosts):"
cat ~/.ssh/id_ed25519.pub
echo "Install Termux:Boot from F-Droid so sshd autostarts on reboot."
echo "Wakelock is held. Also exempt Termux + Tailscale from battery optimization"
echo "and add them to Samsung 'Never sleeping apps' so ssh survives screen lock."
EOF
)

# --qr: render a self-extracting one-liner as a terminal QR. The full script is
# too big to QR raw (~2.2 KB → unscannable v40), so ship it gzip+base64-wrapped.
# Scan it on the phone, paste the decoded text into Termux, Enter.
if [ "${1:-}" = "--qr" ]; then
  payload=$(printf '%s\n' "$OUT" | gzip -9 | base64 | tr -d '\n')
  oneliner="echo $payload|base64 -d|gzip -d|bash"
  printf '%s' "$oneliner" | qrencode -t ANSIUTF8 -l L
  printf '\nScan → paste into Termux → Enter (%d-char payload).\n' "${#oneliner}" >&2
  printf 'It is a dense QR; shrink the terminal font so the whole code fits on screen.\n' >&2
else
  printf '%s\n' "$OUT"
fi
