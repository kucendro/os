{
  lib,
  pkgs,
  me,
  ...
}:

let
  mkLauncher =
    name: address:
    let
      launcher = pkgs.writeShellApplication {
        inherit name;
        runtimeInputs = [
          pkgs.android-tools
          pkgs.scrcpy
        ];
        text = ''
          export SDL_VIDEODRIVER=wayland
          adb connect ${address} || true
          for _ in $(seq 1 10); do
            if adb -s ${address} get-state 2>/dev/null | grep -q device; then
              break
            fi
            sleep 0.5
          done
          exec scrcpy -s ${address} "$@"
        '';
      };
    in
    [
      launcher
      (pkgs.makeDesktopItem {
        inherit name;
        desktopName = "${name}";
        comment = "Mirror ${name} (${address}) over the network";
        exec = lib.getExe launcher;
        icon = "phone";
        categories = [ "Utility" ];
      })
    ];
in
{
  environment.systemPackages = lib.concatLists (lib.mapAttrsToList mkLauncher me.phones);
}
