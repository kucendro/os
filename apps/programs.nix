{ pkgs, ... }:

{
  programs.firefox.enable = true;
  programs.appimage.enable = true;
  programs.appimage.binfmt = true;
  programs.evince.enable = true;
  programs.kdeconnect.enable = true;
  programs.nix-ld.enable = true;
  programs.nh.enable = true;
}
