{ pkgs, ... }:
{
  stylix = {
    enable = true;
    targets = {
      console.enable = false;
      chromium.enable = false;
      kmscon.enable = false;
    };
    image = ./wallpaper_wolf.jpg;
    polarity = "dark";
    base16Scheme = ./carbonfox.yaml;
    cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Ice";
      size = 24;
    };
    fonts = {
      serif = {
        package = pkgs.inter;
        name = "Inter";
      };
      sansSerif = {
        package = pkgs.inter;
        name = "Inter";
      };
      monospace = {
        package = pkgs.nerd-fonts.hack;
        name = "Hack Nerd Font Mono";
      };
      emoji = {
        package = pkgs.noto-fonts-color-emoji;
        name = "Noto Color Emoji";
      };
      sizes = {
        applications = 10;
        desktop = 8;
        popups = 10;
        terminal = 10;
      };
    };
  };
}
