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
      rebuild = "~/nixos/rebuild.sh";
      tunnel = "cloudflared tunnel run nixbook";
      wgprod = "nmcli connection up prod";
      wgdev = "nmcli connection up dev";
    };
  };
}
