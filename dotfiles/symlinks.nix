{
  config,
  lib,
  osConfig,
  ...
}:
let
  isNixbook = osConfig.networking.hostName == "nixbook";
  mkSymlink = path: config.lib.file.mkOutOfStoreSymlink "/home/kucendro/nixos/dotfiles/${path}";
in
{
  xdg.configFile = {
    "noctalia/settings.json".source = lib.mkIf isNixbook (mkSymlink "noctalia/settings.json");
    "noctalia/colors.json".source = lib.mkIf isNixbook (mkSymlink "noctalia/colors.json");
    "noctalia/plugins.json".source = lib.mkIf isNixbook (mkSymlink "noctalia/plugins.json");
    "nvim/lazy-lock.json".source = mkSymlink "nvim/lazy-lock.json";
    "nvim/lazyvim.json".source = mkSymlink "nvim/lazyvim.json";
  };
}
