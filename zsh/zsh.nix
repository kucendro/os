{ config, pkgs, ... }:

{
  users.defaultUserShell = pkgs.zsh;

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;

    loginShellInit = ''
      if [ -z "$DISPLAY" ] && [ "$XDG_VTNR" = "1" ]; then
        start-hyprland
      fi
    '';

    shellAliases = {
      rebuild = "~/nixos/rebuild.sh";
    };
  };
}
