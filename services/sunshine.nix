{ lib, pkgs, ... }:

let
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

      monitors=$(hyprctl monitors -j)
      primary=$(jq -r '.[0].name' <<<"$monitors")

      jq -r ".[] | select(.name != \"$primary\") | .name" <<<"$monitors" \
        | while read -r mon; do
            hyprctl keyword monitor "$mon,disabled"
          done

      hyprctl keyword monitor "$primary,''${width}x''${height}@''${fps},0x0,''${scale}"
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
    '';
  };
in
{
  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true;
    openFirewall = true;
    settings = {
      capture = "kms";
      global_prep_cmd = ''[{"do":"${lib.getExe configureMonitors}","undo":"${lib.getExe restoreMonitors}"}]'';
    };
  };

  networking.firewall = {
    trustedInterfaces = [ "tailscale0" ];
    checkReversePath = "loose";
  };
}
