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
  hasDotfiles = !(osConfig.boot.isContainer or false);
  mkSymlink = path: config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos/dotfiles/${path}";
in
{
  xdg.configFile =
    (lib.optionalAttrs isNixbook {
      "noctalia/settings.json".source = lib.mkForce (mkSymlink "noctalia/settings.json");
      "noctalia/plugins.json".source = mkSymlink "noctalia/plugins.json";
    })
    // (lib.optionalAttrs hasDotfiles {
      "nvim/lazy-lock.json".source = mkSymlink "nvim/lazy-lock.json";
      "nvim/lazyvim.json".source = mkSymlink "nvim/lazyvim.json";
    });

  xdg.dataFile = lib.optionalAttrs isNixbook {
    "applications/dev.noctalia.noctalia-qs.desktop".source =
      "${inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default}/share/applications/dev.noctalia.noctalia-qs.desktop";
  };
}
