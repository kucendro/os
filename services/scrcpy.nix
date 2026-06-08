{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.scrcpy;
in
{
  options.services.scrcpy.devices = lib.mkOption {
    description = "Named ADB-over-network devices to generate scrcpy launchers for. The attribute name becomes the launcher command.";
    default = { };
    example = {
      fold.address = "100.64.0.3:5555";
    };
    type = lib.types.attrsOf (
      lib.types.submodule {
        options.address = lib.mkOption {
          type = lib.types.str;
          description = "host:port";
        };
      }
    );
  };

  config.environment.systemPackages = lib.mapAttrsToList (
    name: device:
    pkgs.writeShellApplication {
      inherit name;
      runtimeInputs = [
        pkgs.android-tools
        pkgs.scrcpy
      ];
      text = ''
        adb connect ${device.address} || true
        for _ in $(seq 1 10); do
          if adb -s ${device.address} get-state 2>/dev/null | grep -q device; then
            break
          fi
          sleep 0.5
        done
        exec scrcpy -s ${device.address} "$@"
      '';
    }
  ) cfg.devices;
}
