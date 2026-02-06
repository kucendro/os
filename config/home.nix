{ config, pkgs, ... }:

{
  programs.bash = {
    enable = true;
    shellAliases = {
      rebuild = "~/nixos/rebuild.sh";
    };
  };

  sops = {
    age.keyFile = "/home/kucendro/.config/sops/age/keys.txt";
    defaultSopsFile = ../secrets.yaml;
    secrets.wg-private-key = {};
    secrets.wg-preshared-key = {};
  };
}