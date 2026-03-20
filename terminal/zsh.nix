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
      rebuild = "~/nixos/rebuild.sh";
      ls = "lsd";
      cl = "clear";
      ex = "exit";
      tunnel = "cloudflared tunnel run nixbook";
      wg-prod-up = "nmcli connection up prod";
      wg-prod-down = "nmcli connection down prod";
      wg-prod-status = "nmcli connection show prod";
      wg-dev-up = "nmcli connection up test";
      wg-dev-down = "nmcli connection down test";
      wg-dev-status = "nmcli connection show test";
    };
  };
}
