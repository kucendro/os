{ pkgs, lib, ... }:

{
  users.defaultUserShell = pkgs.zsh;

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    histSize = 10000;
    enableLsColors = true;
    shellAliases = {
      ls = "lsd";
      cl = "clear";
      ex = "exit";
      tunnel = "cloudflared tunnel run nixbook";
      vibe = "wt switch --create -x --execute=claude";
      k = "kubectl";
      n = "nvim .";
      d = "docker";
      dc = "docker compose";
      gs = "git status";
      ga = "git add .";
      gc = "git commit -m";
    };

    promptInit = ''
      eval "$(any-nix-shell zsh --info-right)"
      export KUBECONFIG=~/.kube/work-prod:~/.kube/work-test
    '';
  };

  environment.systemPackages = [ pkgs.any-nix-shell ];

  programs.starship = {
    enable = true;
    transientPrompt.enable = true;
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
      };
    };
  };

  programs.atuin = {
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
}
