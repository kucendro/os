{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix

    ./config/configuration.nix
    ./config/power-management.nix

    ./vpn/wg.nix
    ./vpn/cloudflared.nix
    ./vpn/warp.nix
    
    ./apps/programs.nix
    ./custom/zenbook.nix
    ./packages/global-packages.nix
    ./home/kucendro.nix
    ./terminal/zsh.nix
    ./display/hyprland.nix
    ./servers/nextcloud.nix

    ./security/auth-methods.nix
    ./security/keychain.nix
    ./security/pam.nix

    ./secrets/sops.nix

    ./sound/airplay.nix
    ./sound/hardware.nix
  ];

  # ! ABSOLUTELY DO NOT CHANGE THE VERSION BELOW YOU MOTHER FUCKER BITCH!
  system.stateVersion = "25.11";
}
