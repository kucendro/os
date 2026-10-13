{
  pkgs,
  lib,
  inputs,
  ...
}:
{
  home.pointerCursor.enable = true;

  home.packages =
    with pkgs;
    [
      glib
      vial
      audacity
      element-desktop
      davinci-resolve
      telegram-desktop
      inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
      wl-clipboard
      wtype
      rofimoji
      fuzzel
      nautilus
      loupe
      qdirstat
      gpu-screen-recorder
      moonlight-qt
      gnome-network-displays
      nwg-displays
      adwaita-icon-theme
      gnome-keyring
      grim
      slurp
    ]
    ++ lib.attrValues (import ../packages/artcraft.nix { inherit pkgs lib; });

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
