#!/data/data/com.termux/files/usr/bin/bash
set -e

pkg upgrade -y
pkg install -y openssh mosh tmux curl

[ -d ~/storage ] || termux-setup-storage
mkdir -p ~/.ssh ~/.termux

cat > ~/.ssh/config <<'CONFIG_EOF'
Host nixbook
  HostName nixbook.ts.kucendro.dev
  User kucendro
  Port 22
  IdentityFile ~/.ssh/id_ed25519
Host nas
  HostName nas.ts.kucendro.dev
  User kucendro
  Port 22
  IdentityFile ~/.ssh/id_ed25519
Host edge
  HostName edge.ts.kucendro.dev
  User kucendro
  Port 22
  IdentityFile ~/.ssh/id_ed25519
Host mac
  HostName mac.ts.kucendro.dev
  User kucendro
  Port 22
  IdentityFile ~/.ssh/id_ed25519
CONFIG_EOF
chmod 600 ~/.ssh/config

[ -f ~/.ssh/id_ed25519 ] || ssh-keygen -t ed25519 -N "" -C "kucendro@fold" -f ~/.ssh/id_ed25519

cat > ~/.termux/colors.properties <<'COLORS_EOF'
background=#161616
foreground=#f2f4f8
cursor=#f2f4f8
color0=#161616
color1=#ee5396
color2=#25be6a
color3=#08bdba
color4=#78a9ff
color5=#be95ff
color6=#33b1ff
color7=#f2f4f8
color8=#484848
color9=#ee5396
color10=#25be6a
color11=#08bdba
color12=#78a9ff
color13=#be95ff
color14=#33b1ff
color15=#e4e4e5
COLORS_EOF

cat > ~/.termux/termux.properties <<'PROPS_EOF'
extra-keys = [['ESC','/','-','HOME','UP','END'],['TAB','CTRL','ALT','LEFT','DOWN','RIGHT']]
fullscreen = true
PROPS_EOF

[ -f ~/.termux/font.ttf ] || curl -fsSL 'https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Hack/Regular/HackNerdFontMono-Regular.ttf' -o ~/.termux/font.ttf

cat >> ~/.bashrc <<'BASHRC_EOF'
if [[ $- == *i* && -z $TMUX && -z $SSH_CONNECTION ]]; then
  if ssh -o ConnectTimeout=3 -o BatchMode=yes nixbook true 2>/dev/null; then
    exec mosh nixbook -- tmux a
  else
  exec tmux new-session -A -s fold
  fi
fi
BASHRC_EOF

termux-reload-settings

echo
echo "------------------------------------"
echo "fold LINKED SON"
echo "------------------------------------"

cat ~/.ssh/id_ed25519.pub
