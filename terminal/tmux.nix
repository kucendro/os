{ pkgs, ... }:
{
  programs.tmux = {
  shell = "${pkgs.bash}/bin/zsh";
  baseIndex = 1;
  newSession = true;
  enable = true;
  escapeTime = 0;
  secureSocket = false;
  mouse = true;
  clock24 = true;
  historyLimit = 50000;
  plugins = with pkgs; [
      tmuxPlugins.better-mouse-mode
    ];
}
}