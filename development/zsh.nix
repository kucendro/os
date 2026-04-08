{ pkgs, ... }:

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
      ardmonitor = "arduino-cli monitor -p $PORT";
    };
  };
}
