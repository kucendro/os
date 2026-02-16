{ config, pkgs, ... }:

{
  users.defaultUserShell = pkgs.zsh;

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;

    # loginShellInit = ''
    #   if [ -z "$DISPLAY" ] && [ "$XDG_VTNR" = "1" ]; then
    #     start-hyprland
    #   fi
    # '';

    shellAliases = {
      rebuild = "~/nixos/rebuild.sh";
      worklouder = "appimage-run input-0.13.2-Community.AppImage";
      kdrive = "appimage-run kDrive-3.7.9.1-amd64.AppImage";
    };
  };
}
