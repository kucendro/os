{
  pkgs,
  lib,
  ...
}:
{
  home.pointerCursor.enable = true;

  services = {
    kdeconnect = {
      enable = true;
      indicator = true;
    };

    kdeconnectRunCommands.commands = {
      "vol down" = "noctalia-shell ipc call volume decrease";
      "vol up" = "noctalia-shell ipc call volume increase";
      "mute" = "noctalia-shell ipc call volume muteoutput";
      "lock" = "hyprlock";
      "suspend" = "noctalia-shell ipc call sessionmenu lockandsuspend";
    };

    udiskie = {
      enable = true;
      settings = {
        program_options = {
          file_manager = "${pkgs.nautilus}/bin/nautilus";
        };
      };
    };
  };

  programs = {
    noctalia-shell.enable = true;

    chromium = {
      enable = true;
      commandLineArgs = [
        "--hide-crash-restore-bubble"
        "--restore-last-session"
      ];
    };

    kitty = lib.mkForce {
      enable = true;
      settings = {
        confirm_os_window_close = 0;
        dynamic_background_opacity = true;
        enable_audio_bell = false;
        mouse_hide_wait = "-1.0";
        background_blur = 5;
      };
    };
  };
}
