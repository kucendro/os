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
        tmux attach-session -t default || tmux new-session -s default
      fi
    '';

    shellAliases = {
      rebuild = "~/nixos/rebuild.sh";
      tunnel = "cloudflared tunnel run nixbook";

    };
  };
}
