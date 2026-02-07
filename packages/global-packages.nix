{ config, pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    wget
    wine64
    fastfetch
    btop
    sops
    age
    owntone
    nixfmt
    kitty
    adwaita-icon-theme
  ];
}