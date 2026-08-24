: "${CLOUD_URL:?}" "${LOGIN_SERVER:?}" "${SSH_CONFIG:?}" "${REACHES:?}" "${DEFAULT_REMOTE:?}"

TARGET=10.11.99.1
AUTHKEY=""

case "${1:-}" in
-h | --help)
  cat >&2 <<USAGE_EOF
remarkable [authkey]    link the tablet over usb (root@${TARGET})
first link needs a key: sudo headscale preauthkeys create --user <id>
USAGE_EOF
  exit 0
  ;;
"") ;;
-*)
  echo "unknown arg: $1" >&2
  exit 1
  ;;
*)
  AUTHKEY="$1"
  ;;
esac

if [ -n "$AUTHKEY" ]; then
  JOIN="\$TS up --login-server ${LOGIN_SERVER} --authkey ${AUTHKEY}"
else
  JOIN=$(
    cat <<'JOIN_EOF'
echo "not joined, mint a key on edge: sudo headscale preauthkeys create --user <id>" >&2
  exit 1
JOIN_EOF
  )
fi

PICKER=$(
  cat <<PICKER_EOF
if [[ \$- == *i* && -z \$TMUX && -z \$SSH_CONNECTION ]]; then
  remotes=(${REACHES})
  default=${DEFAULT_REMOTE}
  echo ""
  echo "  pick target (enter=\$default, l=local, 3s timeout):"
  i=1
  for r in "\${remotes[@]}"; do
    mark=""; [ "\$r" = "\$default" ] && mark="  *"
    printf '    %d)  %s%s\n' "\$i" "\$r" "\$mark"
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
      exec ssh -t "\$target" tmux new -A -s remarkable
    else
      echo "\$target unreachable"
    fi
  fi
fi
PICKER_EOF
)

OUT=$(
  cat <<EOF
#!/bin/bash
set -e
export PATH=/opt/bin:/opt/sbin:\$PATH

if [ ! -x /opt/bin/opkg ]; then
  wget -q https://toltec-dev.org/bootstrap -O /home/root/bootstrap
  bash /home/root/bootstrap
elif [ -x /opt/bin/toltecctl ]; then
  toltecctl reenable || true
fi
opkg update
opkg install tailscale tailscale-systemd yaft fingerterm remux openssh-client openssh-keygen
systemctl daemon-reload
systemctl enable --now tailscaled
systemctl enable --now remux

TS="/opt/bin/tailscale --socket=/opt/var/run/tailscale/tailscaled.sock"
if ! \$TS status >/dev/null 2>&1; then
  ${JOIN}
fi

cd /home/root
wget -q https://github.com/ddvk/rmfakecloud-proxy/releases/latest/download/installer.sh -O installer.sh
chmod +x installer.sh
./installer.sh install ${CLOUD_URL}

mkdir -p /etc/systemd/system/proxy.service.d
cat > /etc/systemd/system/proxy.service.d/10-tailscale.conf <<'DROPIN_EOF'
[Service]
Environment=HTTP_PROXY=http://127.0.0.1:1055
Environment=HTTPS_PROXY=http://127.0.0.1:1055
DROPIN_EOF
systemctl daemon-reload
systemctl restart proxy

mkdir -p /home/root/.ssh
cat > /home/root/.ssh/config <<'SSHCFG_EOF'
${SSH_CONFIG}SSHCFG_EOF
chmod 600 /home/root/.ssh/config
[ -f /home/root/.ssh/id_ed25519 ] || ssh-keygen -t ed25519 -N "" -C "root@remarkable" -f /home/root/.ssh/id_ed25519

grep -q "pick target" /home/root/.bashrc 2>/dev/null || cat >> /home/root/.bashrc <<'RC_EOF'
${PICKER}
RC_EOF

echo "linked, pair it: ${CLOUD_URL} -> generate code -> tablet settings > account"
echo "authorize this key on your hosts:"
cat /home/root/.ssh/id_ed25519.pub
EOF
)

printf '%s\n' "$OUT" | ssh "root@${TARGET}" bash
