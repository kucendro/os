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
    nixfmt
    kitty
    adwaita-icon-theme
    nautilus
    gnome-keyring
    libsecret
    rustup
    oxker
    nodejs

    # ? Power & idle management
    brightnessctl
    hypridle
    hyprlock
  ];
}