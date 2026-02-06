{ config, pkgs, ... }:

{
  
  imports =
    [
      ./hardware-configuration.nix
      ./config/configuration.nix
      ./vpns/wg.nix
    ];

  # ! ABSOLUTELY DO NOT CHANGE THE VERSION BELOW YOU MOTHER FUCKER BITCH!
  system.stateVersion = "25.11";

}