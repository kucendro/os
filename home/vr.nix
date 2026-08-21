{ pkgs, ... }:

let
  vrSession = pkgs.writeShellApplication {
    name = "vr";
    runtimeInputs = [
      pkgs.wayvr
      pkgs.lighthouse-steamvr
      pkgs.hyprland
      pkgs.systemd
      pkgs.coreutils
    ];
    text = ''
      lighthouse --state on || true

      systemctl --user start monado

      ipc="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/monado_comp_ipc"
      for _ in $(seq 1 50); do
        [ -S "$ipc" ] && break
        sleep 0.2
      done
      if [ ! -S "$ipc" ]; then
        echo "monado did not come up ($ipc missing); check: journalctl --user -u monado" >&2
        exit 1
      fi

      hyprctl output create headless vr0 || true
      hyprctl keyword monitor "vr0,3440x1440@60,auto,1" || true
      wayvr || true
      hyprctl output remove vr0 || true
      systemctl --user stop monado || true
      lighthouse --state off || true
    '';
  };
in
{
  home.packages = [
    pkgs.wayvr
    vrSession
  ];

  wayland.windowManager.hyprland.settings = {
    permission = [
      "/nix/store/.*/bin/wayvr, screencopy, allow"
    ];

    bind = [
      "$mainMod, V, exec, vr"
    ];
  };
}
