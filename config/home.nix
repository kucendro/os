{ config, pkgs, ... }:

{
  programs.bash = {
    enable = true;
    shellAliases = {
      rebuild = "~/nixos/rebuild.sh";
    };
  };
}