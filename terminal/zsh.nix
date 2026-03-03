{ config, pkgs, ... }:

{
  users.defaultUserShell = pkgs.zsh;

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    histSize = 10000;
    
    shellInit = ''
      if [ -z "$TMUX" ] && [ -n "$DISPLAY" ]; then
        tmux attach-session -t 1 || tmux new-session -s 1
      fi
    '';

    shellAliases = {
      rebuild = "~/nixos/rebuild.sh";
      tunnel = "cloudflared tunnel run nixbook";

    };
  };
}
