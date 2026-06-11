{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.kdeconnectRunCommands;

  mkId =
    name:
    let
      h = builtins.hashString "md5" name;
      s = builtins.substring;
    in
    "${s 0 8 h}_${s 8 4 h}_${s 12 4 h}_${s 16 4 h}_${s 20 12 h}";

  commandsJson = builtins.toJSON (
    lib.mapAttrs' (name: command: lib.nameValuePair (mkId name) { inherit command name; }) cfg.commands
  );

  commandsByteArray = "@ByteArray(${builtins.replaceStrings [ ''"'' ] [ ''\"'' ] commandsJson})";

  runCommandConfig = pkgs.writeText "kdeconnect_runcommand_config" ''
    [General]
    commands="${commandsByteArray}"
  '';
in
{
  options.services.kdeconnectRunCommands.commands = lib.mkOption {
    type = lib.types.attrsOf lib.types.str;
    default = { };
    example = {
      "LOCK" = "hyprlock";
    };
    description = ''
      Declarative kdeconnect "run command" entries, as name -> shell command.
      kdeconnect stores these per paired device under a dynamically-created
      device-id dir with no shared location, so the generated config is written
      into every existing device dir on activation. Devices paired after a
      switch pick it up on the next switch.
    '';
  };

  config = lib.mkIf (cfg.commands != { }) {
    home.activation.kdeconnectRunCommands = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      kdeDir="$HOME/.config/kdeconnect"
      if [ -d "$kdeDir" ]; then
        for dev in "$kdeDir"/*/; do
          [ -d "$dev" ] || continue
          run mkdir -p "''${dev}kdeconnect_runcommand"
          run install -m644 ${runCommandConfig} "''${dev}kdeconnect_runcommand/config"
        done
      fi
    '';
  };
}
