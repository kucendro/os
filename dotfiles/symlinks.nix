{
  config,
  lib,
  osConfig,
  ...
}:
let
  hasDotfiles = !(osConfig.boot.isContainer or false);
  mkSymlink =
    path: config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos/dotfiles/${path}";
in
{
  xdg.configFile = lib.optionalAttrs hasDotfiles {
    "nvim/lazy-lock.json".source = mkSymlink "nvim/lazy-lock.json";
    "nvim/lazyvim.json".source = mkSymlink "nvim/lazyvim.json";
  };
}
