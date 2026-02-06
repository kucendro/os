{ config, pkgs, ... }:

{
  
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./myconfiguration.nix
    ];

  # ! ABSOLUTELY DO NOT CHANGE THE VERSION BELOW YOU MOTHER FUCKER BITCH!
  system.stateVersion = "25.11";

}