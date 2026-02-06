{ config, pkgs, ... }:

{
  programs.firefox.enable = true;
  programs.git.enable = true;
  programs.zsh.enable = true;

  # programs.hyprland = {
  #   enable = true;
  #   withUWSM = true;
  #   xwayland.enable = true;
  # };
}
