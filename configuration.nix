{ config, pkgs, ... }:

{
  
  imports =
    [
      ./hardware-configuration.nix
      ./config/configuration.nix
      ./vpn/wg.nix
      ./config/home.nix
      ./apps/programs.nix
      ./custom/zenbook.nix
      ./packages/global-packages.nix
    ];

  # ! ABSOLUTELY DO NOT CHANGE THE VERSION BELOW YOU MOTHER FUCKER BITCH!
  system.stateVersion = "25.11";

}