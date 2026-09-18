#!/bin/bash
# curl -fsS @ip@:@port@/setup/apt.sh | sudo bash
set -e
export DEBIAN_FRONTEND=noninteractive NEEDRESTART_MODE=a

main() {
  cat >/usr/local/bin/apt-proxy-detect <<'EOF'
#!/bin/bash
if timeout 1 bash -c 'exec 3<>/dev/tcp/@ip@/@port@' 2>/dev/null; then
  echo http://@ip@:@port@
else
  echo DIRECT
fi
EOF
  chmod +x /usr/local/bin/apt-proxy-detect
  printf '%s\n' \
    'Acquire::http::Proxy-Auto-Detect "/usr/local/bin/apt-proxy-detect";' \
    'Acquire::Retries "5";' \
    >/etc/apt/apt.conf.d/00proxy-autodetect

  set +e
  failed=()
  install() { apt-get install -y -m "$@" || failed+=("$1"); }

  apt-get update
  apt-get dist-upgrade -y || failed+=(dist-upgrade)
  # 1 system, locale, manuals, info, scheduling
  install man-db manpages manpages-dev manpages-cs language-pack-cs at lshw inxi sysstat
  # 2 accounts, remote access, filesystems, permissions, backup, archives
  install openssh-server libpam-pwquality fail2ban ufw acl attr tree ncdu mc parted gdisk lvm2 xfsprogs btrfs-progs dosfstools ntfs-3g rsync zip unzip p7zip-full borgbackup restic
  # 3 console, web server with php, sftp, database
  install tmux screen vim nano bash-completion curl wget git sshfs apache2 libapache2-mod-php php php-cli php-fpm php-mysql php-curl php-xml php-mbstring php-zip php-gd mariadb-server mariadb-client phpmyadmin
  # 4 processes, signals, monitoring, logs, network, firewall, nat, vpn
  install htop btop atop iotop iftop nethogs glances psmisc lsof strace ltrace stress-ng lnav smartmontools net-tools dnsutils traceroute mtr-tiny tcpdump nmap netcat-openbsd iperf3 socat whois ethtool iptables nftables wireguard openvpn easy-rsa dnsmasq

  if [ ${#failed[@]} -gt 0 ]; then
    echo "FAILED: ${failed[*]}, run the script again" >&2
    exit 1
  fi
  echo "OK, everything installed"
}

main
