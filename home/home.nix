{ config, pkgs, ... }:

{
  imports = [
    ../development/neovim.nix
    ../terminal/tmux.nix
    ../development/git.nix
  ];
  home.username = "kucendro";
  home.homeDirectory = "/home/kucendro";

  # Noctalia shell configuration
  xdg.configFile = {
    "noctalia/settings.json".source =
      config.lib.file.mkOutOfStoreSymlink "/home/kucendro/nixos/display/noctalia/settings.json";
    "noctalia/colors.json".source =
      config.lib.file.mkOutOfStoreSymlink "/home/kucendro/nixos/display/noctalia/colors.json";
    "noctalia/plugins.json".source =
      config.lib.file.mkOutOfStoreSymlink "/home/kucendro/nixos/display/noctalia/plugins.json";
    "hypridle/hypridle.conf".source =
      config.lib.file.mkOutOfStoreSymlink "/home/kucendro/nixos/display/hypridle/hypridle.conf";
    "hyprlock/hyprlock.conf".source =
      config.lib.file.mkOutOfStoreSymlink "/home/kucendro/nixos/display/hyprlock/hyprlock.conf";
  };

  programs.home-manager.enable = true;

   programs.ssh = {
     enable = true;
     addKeysToAgent = "yes";
     matchBlocks."github.com" = {
       hostname = "github.com";
       user = "git";
       identityFile = "/home/kucendro/.ssh/github_ed25519";
       identitiesOnly = true;
     };
   };

   services.ssh-agent.enable = true;

  services.udiskie = {
    enable = true;
    settings = {
      program_options = {
        file_manager = "${pkgs.nautilus}/bin/nautilus";
      };
    };
  };

  # ! DO NOT CHANGE
  home.stateVersion = "25.11";
}
