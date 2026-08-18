{
  pkgs,
  lib,
  me,
}:

let
  loginServer = "https://edge.kucendro.dev";

  devPackages = import ../development/dev-packages.nix pkgs;

  glue = with pkgs; [
    tailscale
    coreutils
    bashInteractive
    cacert
    iproute2
    git
    curl
    mosh
    tmux
    neovim
    nvtopPackages.nvidia
  ];

  contents = devPackages ++ glue;

  entrypoint = pkgs.writeShellApplication {
    name = "workstation-entrypoint";
    runtimeInputs = glue;
    text = ''
      : "''${TS_AUTHKEY:?set TS_AUTHKEY in the pod environment}"

      state_dir="''${TS_STATE_DIR:-/workspace/tailscale}"
      login_server="''${TS_LOGIN_SERVER:-${loginServer}}"
      hostname="''${TS_HOSTNAME:-${me.name}-pod}"
      tun="''${TS_TUN:-userspace-networking}"

      mkdir -p "$state_dir" /var/run/tailscale

      tailscaled \
        --state="$state_dir/tailscaled.state" \
        --socket=/var/run/tailscale/tailscaled.sock \
        --tun="$tun" &

      sleep 2

      tailscale up \
        --ssh \
        --authkey="$TS_AUTHKEY" \
        --login-server="$login_server" \
        --hostname="$hostname" \
        --accept-routes

      echo "tailscale up as $hostname; reachable over the tailnet via ssh."
      exec sleep infinity
    '';
  };
in
pkgs.dockerTools.buildLayeredImage {
  name = "workstation";
  tag = "latest";
  contents = contents ++ [ entrypoint ];
  config = {
    Env = [
      "PATH=/bin:${lib.makeBinPath contents}"
      "SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
      "NIX_SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
      "HOME=/root"
      "TERM=xterm-256color"
    ];
    Cmd = [ "${entrypoint}/bin/workstation-entrypoint" ];
    WorkingDir = "/root";
  };
}
