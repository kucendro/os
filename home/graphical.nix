{ pkgs, lib, ... }:
{
  home.pointerCursor.enable = true;

  home.packages = with pkgs; [
    sshfs
    glib
    vial
  ];

  services = {
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
