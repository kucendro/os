{ pkgs, ... }:
{
  programs.tmux = {
    baseIndex = 1;
    newSession = true;
    enable = true;
    escapeTime = 0;
    secureSocket = false;
    focusEvents = true;
    clock24 = true;
    historyLimit = 50000;
    shortcut = "space";
    extraConfig = ''
      set -g @resurrect-strategy-nvim 'session'
      set -g @continuum-restore 'on'
      set -g @continuum-save-interval '10'
    '';
    plugins = with pkgs; [
      tmuxPlugins.better-mouse-mode
      tmuxPlugins.catppuccin
      tmuxPlugins.dotbar
      tmuxPlugins.resurrect
      tmuxPlugins.continuum
    ];
  };
}
