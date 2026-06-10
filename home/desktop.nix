{
  pkgs,
  lib,
  ...
}:

{
  programs."noctalia-shell" = {
    enable = true;
  };

  stylix.targets = {
    # neovim.enable = false;
    # inkscape.enable = false;
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
