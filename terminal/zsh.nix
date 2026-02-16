{ config, pkgs, ... }:

{
  users.defaultUserShell = pkgs.zsh;

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      rebuild = "~/nixos/rebuild.sh";
      worklouder = "appimage-run input-0.13.2-Community.AppImage";
      kdrive = "appimage-run kDrive-3.7.9.1-amd64.AppImage";
    };
  };
}
