{ config, pkgs, ... }:

{
  # programs.firefox.enable = true;
  # programs.git.enable = true;
  # programs.zsh.enable = true;
  # programs.appimage.enable = true;
  # programs.appimage.binfmt = true;
  # programs.evince.enable = true;


  programs = [
    firefox.enable
    zsh.enable
    git.enable
    evince.enable
    appimage.enable
    appimage.binfmt
  ];

}
