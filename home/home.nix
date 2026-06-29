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
    ../dotfiles/symlinks.nix
    ../development/docker.nix
    ../development/tools.nix
  ]

  ++ lib.optionals (profile == "desktop") [
    inputs.noctalia.homeModules.default
    ../display/hyprland.nix
    ../services/kdeconnect.nix
    ./desktop.nix
  ];

  home.username = me.name;
  home.homeDirectory =
    if pkgs.stdenv.hostPlatform.isDarwin then "/Users/${me.name}" else "/home/${me.name}";

  home.sessionVariables = {
    KUBECONFIG = "${config.home.homeDirectory}/.kube/work-prod:${config.home.homeDirectory}/.kube/work-test";
    PNPM_HOME = "${config.home.homeDirectory}/.local/share/pnpm";
  };

  home.sessionPath = [ "${config.home.homeDirectory}/.local/share/pnpm" ];

  home.packages = with pkgs; [
    fd
    lsd
    tldr
    jq
    yq
  ];

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
      options = "--delete-older-than 3d";
    };
  };

  programs = {

    ssh = {
      enable = true;
      matchBlocks = {
        mac.user = me.name;
        workstation.user = me.name;
        edge.user = me.name;
        fold =
          let
            peer = import ../targets/fold/peer.nix;
          in
          {
            hostname = lib.head (lib.splitString ":" me.phones.fold);
            user = peer.ssh.user;
            port = peer.ssh.port;
            serverAliveInterval = 30;
            serverAliveCountMax = 3;
            extraOptions.ConnectionAttempts = "3";
          };
      };
    };

    qutebrowser = lib.mkIf (profile == "desktop") {
      enable = true;
      searchEngines = {
        DEFAULT = "https://duckduckgo.com/?q={}";
        g = "https://www.google.com/search?hl=en&q={}";
        n = "https://search.nixos.org/packages?channel=25.11&query={}";
        w = "https://en.wikipedia.org/wiki/Special:Search?search={}&go=Go&ns0=1";
        v = "https://vault.home.kucendro.dev/#/vault?search={}";
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

    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      history.size = 10000;
      shellAliases = {
        ls = "lsd";
        cl = "clear";
        ex = "exit";
        k = "kubectl";
        n = "nvim .";
        d = "docker";
        dc = "docker compose";
        d-clean-non-destruct = "docker builder prune -a && docker image prune -a";
        gs = "git status";
        ga = "git add .";
        gc = "git commit -m";
        gp = "git push";
        gd = "git diff";
        link-phone = "adb tcpip 5555";

      };
      initContent = ''
        eval "$(${pkgs.any-nix-shell}/bin/any-nix-shell zsh --info-right)"
      '';
      plugins = with pkgs; [
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

    starship = {
      enable = true;
      enableTransience = true;
      settings = {
        format = lib.concatStrings [
          "$custom"
          "$nix_shell"
          "$all"
        ];
        nix_shell = {
          disabled = false;
          symbol = "❄️";
          format = "[$symbol]($style) ";
          style = "bold cyan";
          heuristic = false;
        };
        custom = {
          fhs = {
            command = "echo 🐧";
            when = "[ -e /lib/libc.so.6 ]";
            format = "[$output]($style) ";
            style = "bold blue";
          };
          darwin = {
            command = "echo ";
            when = ''[ "$(uname)" = "Darwin" ]'';
            format = "[$output]($style) ";
            style = "bold white";
          };
        };
      };
    };

    atuin = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        auto_sync = false;
        update_check = false;
        style = "compact";
        inline_height = 20;
        show_preview = true;
        exit_mode = "return-query";
        filter_mode_shell_up_key_binding = "session";
        filter_mode = "global";
      };
    };
  };

  home.stateVersion = "25.11";
}
