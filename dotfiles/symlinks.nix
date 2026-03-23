{ config, ... }:
{
  xdg.configFile = {
    "noctalia/settings.json".source =
      config.lib.file.mkOutOfStoreSymlink "/home/kucendro/nixos/dotfiles/noctalia/settings.json";
    "noctalia/colors.json".source =
      config.lib.file.mkOutOfStoreSymlink "/home/kucendro/nixos/dotfiles/noctalia/colors.json";
    "noctalia/plugins.json".source =
      config.lib.file.mkOutOfStoreSymlink "/home/kucendro/nixos/dotfiles/noctalia/plugins.json";
    "hypridle/hypridle.conf".source =
      config.lib.file.mkOutOfStoreSymlink "/home/kucendro/nixos/dotfiles/hypridle.conf";
    "hyprlock/hyprlock.conf".source =
      config.lib.file.mkOutOfStoreSymlink "/home/kucendro/nixos/dotfiles/hyprlock.conf";
    "hypr/hyprland.conf".source =
      config.lib.file.mkOutOfStoreSymlink "/home/kucendro/nixos/dotfiles/hyprland.conf";
    "nvim/init.lua".source =
      config.lib.file.mkOutOfStoreSymlink "/home/kucendro/nixos/dotfiles/nvim/init.lua";
    "nvim/lazy-lock.json".source =
      config.lib.file.mkOutOfStoreSymlink "/home/kucendro/nixos/dotfiles/nvim/lazy-lock.json";
    "nvim/lazyvim.json".source =
      config.lib.file.mkOutOfStoreSymlink "/home/kucendro/nixos/dotfiles/nvim/lazyvim.json";
  };
}
