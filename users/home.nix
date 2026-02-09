{ config, pkgs, ... }:

{
  home.username = "kucendro";
  home.homeDirectory = "/home/kucendro";

  # Noctalia shell configuration
  xdg.configFile = {
    "noctalia/settings.json".source = config.lib.file.mkOutOfStoreSymlink "/home/kucendro/nixos/display/noctalia/settings.json";
    "noctalia/colors.json".source = config.lib.file.mkOutOfStoreSymlink "/home/kucendro/nixos/display/noctalia/colors.json";
    "noctalia/plugins.json".source = config.lib.file.mkOutOfStoreSymlink "/home/kucendro/nixos/display/noctalia/plugins.json";
    "hypridle/hypridle.conf".source = config.lib.file.mkOutOfStoreSymlink "/home/kucendro/nixos/display/hypridle/hypridle.conf";
    "hyprlock/hyprlock.conf".source = config.lib.file.mkOutOfStoreSymlink "/home/kucendro/nixos/display/hyprlock/hyprlock.conf";
  };

  programs.home-manager.enable = true;

  # ! DO NOT CHANGE
  home.stateVersion = "25.11";
}
