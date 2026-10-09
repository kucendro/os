{
  config,
  lib,
  pkgs,
  ...
}:

let
  streamOutput = "sunshine";
  port = config.services.sunshine.settings.port;

  ensureHis = ''
    if [ -z "''${HYPRLAND_INSTANCE_SIGNATURE:-}" ]; then
      runtime_dir="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
      HYPRLAND_INSTANCE_SIGNATURE=$(
        find "$runtime_dir/hypr" -mindepth 1 -maxdepth 1 -printf '%T@ %f\n' 2>/dev/null \
          | sort -rn | head -1 | cut -d' ' -f2-
      )
      export HYPRLAND_INSTANCE_SIGNATURE
    fi
  '';

  configureMonitors = pkgs.writeShellApplication {
    name = "sunshine-configure-monitors";
    runtimeInputs = with pkgs; [
      hyprland
      jq
      coreutils
      findutils
    ];
    text = ''
      ${ensureHis}
      width="''${SUNSHINE_CLIENT_WIDTH:-1920}"
      height="''${SUNSHINE_CLIENT_HEIGHT:-1080}"
      fps="''${SUNSHINE_CLIENT_FPS:-60}"
      scale="''${SUNSHINE_CLIENT_SCALE:-1}"

      if ! hyprctl monitors all -j | jq -e '.[] | select(.name == "${streamOutput}")' >/dev/null; then
        hyprctl output create headless ${streamOutput}
      fi
      hyprctl keyword monitor "${streamOutput},''${width}x''${height}@''${fps},0x0,''${scale}"

      hyprctl monitors -j | jq -r '.[] | select(.name != "${streamOutput}") | .name' \
        | while read -r mon; do
            hyprctl keyword monitor "$mon,disable"
          done
    '';
  };

  restoreMonitors = pkgs.writeShellApplication {
    name = "sunshine-restore-monitors";
    runtimeInputs = with pkgs; [
      hyprland
      coreutils
      findutils
    ];
    text = ''
      ${ensureHis}
      hyprctl reload
      hyprctl output remove ${streamOutput}
    '';
  };
in
{
  services.sunshine = {
    enable = true;
    autoStart = true;
    settings = {
      capture = "wlr";
      global_prep_cmd = ''[{"do":"${lib.getExe configureMonitors}","undo":"${lib.getExe restoreMonitors}"}]'';
    };
  };

  mesh = {
    ports = {
      sunshine-https = port - 5;
      sunshine = port;
      sunshine-web = port + 1;
      sunshine-rtsp = port + 21;
    };
    udp = map (offset: port + offset) [
      9
      10
      11
      13
      21
    ];
  };
}
