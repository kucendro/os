{ config, ... }:
{
  xdg.configFile = {
    "noctalia/settings.json".source = config.lib.file.mkOutOfStoreSymlink "./noctalia/settings.json";
    "noctalia/colors.json".source = config.lib.file.mkOutOfStoreSymlink "./noctalia/colors.json";
    "noctalia/plugins.json".source = config.lib.file.mkOutOfStoreSymlink "./noctalia/plugins.json";
    "hypridle/hypridle.conf".source = config.lib.file.mkOutOfStoreSymlink "./hypridle.conf";
    "hyprlock/hyprlock.conf".source = config.lib.file.mkOutOfStoreSymlink "./hyprlock.conf";
    "nvim/init.lua".source = config.lib.file.mkOutOfStoreSymlink "./nvim/init.lua";
    "nvim/lazy-lock.json".source = config.lib.file.mkOutOfStoreSymlink "./nvim/lazy-lock.json";
    "nvim/lazyvim.json".source = config.lib.file.mkOutOfStoreSymlink "./nvim/lazyvim.json";
  };
}
