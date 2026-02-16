{ config, pkgs, ... }:

{
  programs.firefox.enable = true;
  programs.git.enable = true;
  programs.appimage.enable = true;
  programs.appimage.binfmt = true;
  programs.evince.enable = true;
  programs.kdeconnect.enable = true;
}
