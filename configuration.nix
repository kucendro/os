{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./config/configuration.nix
    ./secrets/sops.nix
    ./vpn/wg.nix
    ./apps/programs.nix
    ./custom/zenbook.nix
    ./packages/global-packages.nix
    ./users/kucendro.nix
    ./zsh/zsh.nix
    ./display/hyprland.nix
    ./display/gnome.nix
    ./servers/nextcloud.nix
  ];

  # ! ABSOLUTELY DO NOT CHANGE THE VERSION BELOW YOU MOTHER FUCKER BITCH!
  system.stateVersion = "25.11";

}
