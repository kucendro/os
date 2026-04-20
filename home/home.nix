{
  pkgs,
  lib,
  ...
}:

{
  imports = [
    ../development/neovim.nix
    ../development/tmux.nix
    ../development/git.nix
    ../development/opencode.nix
    ../dotfiles/symlinks.nix
    ../display/hyprland.nix
  ];

  home.username = "kucendro";
  home.homeDirectory = "/home/kucendro";

  programs.home-manager.enable = true;

  nix = {
    settings = {
      auto-optimise-store = true;
      warn-dirty = false;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  services.ssh-agent.enable = true;

  stylix.targets.neovim.enable = false;

  programs.kitty = lib.mkForce {
    enable = true;
    settings = {
      confirm_os_window_close = 0;
      dynamic_background_opacity = true;
      enable_audio_bell = false;
      mouse_hide_wait = "-1.0";
      background_blur = 5;
    };
  };

  services.udiskie = {
    enable = true;
    settings = {
      program_options = {
        file_manager = "${pkgs.nautilus}/bin/nautilus";
      };
    };
  };

  home.stateVersion = "25.11";
}
