{
  config,
  pkgs,
  lib,
  inputs,
  profile,
  me,
  ...
}:

{
  imports = [
    ../development/neovim.nix
    ../development/tmux.nix
    ../development/git.nix
    ../development/opencode.nix
    ../dotfiles/symlinks.nix
  ]
  ++ lib.optionals (profile == "desktop") [
    inputs.noctalia.homeModules.default
    ../display/hyprland.nix
    ./desktop.nix
  ];

  home.username = me.name;
  home.homeDirectory =
    if pkgs.stdenv.hostPlatform.isDarwin then "/Users/${me.name}" else "/home/${me.name}";

  home.sessionVariables = {
    KUBECONFIG = "${config.home.homeDirectory}/.kube/work-prod:${config.home.homeDirectory}/.kube/work-test";
  };

  programs.home-manager = {
    enable = true;
  };

  nix = {
    settings = {
      auto-optimise-store = true;
      warn-dirty = false;
      allowed-users = [ me.name ];
    };
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 7d";
    };
  };

  programs = {
    ssh = {
      enable = true;
      matchBlocks = {
        mac = {
          hostname = "mac.local";
          user = me.name;
        };
        workstation = {
          hostname = "10.100.0.1";
          user = me.name;
        };
        "workstation-fallback" = {
          hostname = "mac.local";
          port = 2222;
          user = me.name;
        };
      };
    };

    qutebrowser = {
      enable = true;
      searchEngines = {
        DEFAULT = "https://duckduckgo.com/?q={}";
        g = "https://www.google.com/search?hl=en&q={}";
        n = "https://search.nixos.org/packages?channel=25.11&query={}";
        w = "https://en.wikipedia.org/wiki/Special:Search?search={}&go=Go&ns0=1";
        v = "https://vault.kucendro.dev/#/vault?search={}";
      };
      settings = {
        "colors.webpage.darkmode.enabled" = true;

        "content.cookies.accept" = "no-3rdparty";
        "content.geolocation" = "ask";
        "content.notifications.enabled" = "ask";

        "content.autoplay" = true;

        "downloads.location.directory" = "~/Downloads";
        "downloads.location.prompt" = false;

        "tabs.show" = "multiple";
        "statusbar.show" = "in-mode";
        "scrolling.smooth" = true;
        "fonts.default_family" = "monospace";
        "fonts.default_size" = "11pt";

        "auto_save.session" = true;
        "session.lazy_restore" = true;
      };
      keyBindings = {
        normal = {
          "J" = "tab-prev";
          "K" = "tab-next";
        };
      };
    };

    zsh.plugins = with pkgs; [
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
  };

  home.stateVersion = "25.11";
}
