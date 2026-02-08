{ config, pkgs, ... }:

{
  home.username = "kucendro";
  home.homeDirectory = "/home/kucendro";

  # Noctalia shell configuration (mutable - symlinks to repo, editable via UI)
  xdg.configFile = {
    "noctalia/settings.json".source = config.lib.file.mkOutOfStoreSymlink "/home/kucendro/nixos/display/noctalia/settings.json";
    "noctalia/colors.json".source = config.lib.file.mkOutOfStoreSymlink "/home/kucendro/nixos/display/noctalia/colors.json";
    "noctalia/plugins.json".source = config.lib.file.mkOutOfStoreSymlink "/home/kucendro/nixos/display/noctalia/plugins.json";
    "hypr/hypridle.conf".source = config.lib.file.mkOutOfStoreSymlink "/home/kucendro/nixos/display/hyprland/hypridle.conf";
  };

  # Let Home Manager manage itself
  programs.home-manager.enable = true;

  # DO NOT CHANGE - matches your system.stateVersion
  home.stateVersion = "25.11";
}
