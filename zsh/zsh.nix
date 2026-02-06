{ config, pkgs, ... }:

{
  programs.zsh = {
  enable = true;
  enableCompletion = true;
  autosuggestion.enable = true;
  syntaxHighlighting.enable = true;

  shellAliases = {
    rebuild = "~/nixos/rebuild.sh";
  };
  history.size = 10000;
};
}