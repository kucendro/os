#
#script for linking termux
#

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

#
# theme polysh
#
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

#
# keyboard fixes
#

EXTRA_KEYS="extra-keys = [['ESC','/','-','HOME','UP','END'],['TAB','CTRL','ALT','LEFT','DOWN','RIGHT']]"

#
# try to autoattach session on default remote
#

AUTO_CONNECT=$(
  cat <<AC_EOF
if [[ \$- == *i* && -z \$TMUX && -z \$SSH_CONNECTION ]]; then
  remotes=(${REACHES})
  default=${DEFAULT_REMOTE}
  echo ""
  echo ""
  echo "  pick target (enter=\$default, l=local, 3s timeout):"
  echo ""
  i=1
  for r in "\${remotes[@]}"; do
    mark=""; [ "\$r" = "\$default" ] && mark="  *"
    printf '    %d)  %s%s\n\n' "\$i" "\$r" "\$mark"
    i=\$((i+1))
  done
  read -r -t 3 -p "> " choice || choice=""
  case "\$choice" in
    "")        target="\$default" ;;
    l|local)   target="" ;;
    *[!0-9]*)  target="\$choice" ;;
    *)         target="\${remotes[\$((choice-1))]:-\$default}" ;;
  esac
  if [ -n "\$target" ]; then
    if ssh -o ConnectTimeout=3 -o BatchMode=yes "\$target" true 2>/dev/null; then
      exec mosh "\$target" -- tmux new -A -s ${PHONE_NAME}
    else
      echo "\$target unreachable"
    fi
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
