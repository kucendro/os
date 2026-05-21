{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

{
  imports = [
    ../development/neovim.nix
    ../development/tmux.nix
    ../development/git.nix
    ../development/opencode.nix
    ../dotfiles/symlinks.nix
    inputs.noctalia.homeModules.default
    ../display/hyprland.nix
  ];

  home.username = "kucendro";
  home.homeDirectory = "/home/kucendro";

  home.sessionVariables = {
    KUBECONFIG = "${config.home.homeDirectory}/.kube/work-prod:${config.home.homeDirectory}/.kube/work-test";
  };

  programs.home-manager = {
    enable = true;
  };

  gtk.gtk4.theme = config.gtk.theme;

  nix = {
    settings = {
      auto-optimise-store = true;
      warn-dirty = false;
      allowed-users = [ "kucendro" ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  services.ssh-agent.enable = true;

  programs."noctalia-shell" = {
    enable = true;
  };

  stylix.targets = {
    # neovim.enable = false;
  };

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

  programs.zsh.plugins = with pkgs; [
    {
      name = "zsh-autopair";
      src = fetchFromGitHub {
        owner = "hlissner";
        repo = "zsh-autopair";
        rev = "34a8bca0c18fcf3ab1561caef9790abffc1d3d49";
        sha256 = "1h0vm2dgrmb8i2pvsgis3lshc5b0ad846836m62y8h3rdb3zmpy1";
      };
      file = "autopair.zsh";
    }
    {
      name = "fzf-tab";
      src = "${pkgs.zsh-fzf-tab}/share/fzf-tab";
      file = "fzf-tab.plugin.zsh";
    }
    {
      name = "zsh-you-should-use";
      src = "${pkgs.zsh-you-should-use}/share/zsh/plugins/you-should-use";
      file = "you-should-use.plugin.zsh";
    }
  ];

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
