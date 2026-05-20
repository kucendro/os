{
  config,
  lib,
  osConfig,
  inputs,
  pkgs,
  ...
}:
let
  isNixbook = osConfig.networking.hostName == "nixbook";
  mkSymlink = path: config.lib.file.mkOutOfStoreSymlink "/home/kucendro/nixos/dotfiles/${path}";
  noctaliaPkg = inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default;
in
{
  xdg.configFile = {
    "noctalia/settings.json".source = lib.mkIf isNixbook (
      lib.mkForce (mkSymlink "noctalia/settings.json")
    );
    "noctalia/plugins.json".source = lib.mkIf isNixbook (mkSymlink "noctalia/plugins.json");
    "nvim/lazy-lock.json".source = mkSymlink "nvim/lazy-lock.json";
    "nvim/lazyvim.json".source = mkSymlink "nvim/lazyvim.json";
  };

  xdg.dataFile."applications/dev.noctalia.noctalia-qs.desktop".source =
    lib.mkIf isNixbook "${noctaliaPkg}/share/applications/dev.noctalia.noctalia-qs.desktop";
}
