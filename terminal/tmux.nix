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
    plugins = with pkgs; [
      tmuxPlugins.better-mouse-mode
      tmuxPlugins.catppuccin
      tmuxPlugins.dotbar
    ];
  };
}
