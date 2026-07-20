{
  pkgs,
  lib,
  ...
}:

{

  services.kdeconnectRunCommands.commands = {
    "Vol DOWN" = "noctalia-shell ipc call volume decrease";
    "Vol UP" = "noctalia-shell ipc call volume increase";
    "MUTE" = "noctalia-shell ipc call volume muteOutput";
    "LOCK" = "hyprlock";
    "SUSPEND" = "noctalia-shell ipc call sessionMenu lockAndSuspend";
  };

  programs."noctalia-shell" = {
    enable = true;
  };

  stylix.targets = {
    # neovim.enable = false;
    # inkscape.enable = false;
  };

  home.pointerCursor.enable = true;

  services.kdeconnect = {
    enable = true;
    indicator = true;
  };

  programs.kitty = lib.mkForce {
    enable = true;
    settings = {
      confirm_os_window_close = 0;
      dynamic_background_opacity = true;
      enable_audio_bell = false;
      mouse_hide_wait = "-1.0";
      background_blur = 5;
    };
  };

  services.udiskie = {
    enable = true;
    settings = {
      program_options = {
        file_manager = "${pkgs.nautilus}/bin/nautilus";
      };
    };
  };
}
