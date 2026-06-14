{ pkgs, ... }:

let
  howdyNotify = pkgs.writeShellApplication {
    name = "howdy-snapshot-notify";
    runtimeInputs = with pkgs; [
      libnotify
      coreutils
      findutils
      gnugrep
      xdg-utils
      loupe
    ];
    text = ''
      SNAP_DIR=/var/log/howdy/snapshots
      STATE_DIR="''${XDG_STATE_HOME:-$HOME/.local/state}/howdy-notify"
      MARKER="$STATE_DIR/last-seen"

      [ -d "$SNAP_DIR" ] || exit 0
      mkdir -p "$STATE_DIR"
      if [ ! -e "$MARKER" ]; then
        touch "$MARKER"
        exit 0
      fi
      new=$(find "$SNAP_DIR" -maxdepth 1 -type f -name '*.jpg' -newer "$MARKER" 2>/dev/null | sort)
      touch "$MARKER"
      [ -n "$new" ] || exit 0
      count=$(printf '%s\n' "$new" | grep -c .)
      latest=$(printf '%s\n' "$new" | tail -n1)

      {
        action=$(notify-send \
          --app-name=Howdy \
          --urgency=critical \
          --action="open=Open snapshot" \
          "$count failed" \
          "Face auth failed.") || exit 0
        if [ "$action" = "open" ]; then
          xdg-open "$latest" >/dev/null 2>&1 || loupe "$latest" >/dev/null 2>&1 || true
        fi
      } &
    '';
  };

  howdyWatcher = pkgs.writeShellApplication {
    name = "howdy-snapshot-watch";
    runtimeInputs = with pkgs; [
      procps
      coreutils
      howdyNotify
    ];
    text = ''
      while true; do
        while ! pgrep -x hyprlock >/dev/null 2>&1; do sleep 3; done
        while pgrep -x hyprlock >/dev/null 2>&1; do sleep 1; done
        howdy-snapshot-notify || true
      done
    '';
  };
in
{
  home.packages = [ howdyNotify ];

  systemd.user.services.howdy-snapshot-notify = {
    Unit = {
      Description = "Warn about failed face unlock attempts";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${howdyWatcher}/bin/howdy-snapshot-watch";
      Restart = "on-failure";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
}
