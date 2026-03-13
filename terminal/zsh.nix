{ config, pkgs, ... }:

{
  users.defaultUserShell = pkgs.zsh;

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    histSize = 10000;
    shellAliases = {
      ls = "lsd";
      rebuild = "~/nixos/rebuild.sh";
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
