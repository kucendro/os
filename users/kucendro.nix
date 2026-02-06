{ config, pkgs, ... }:

{
  users.users.kucendro = {
    isNormalUser = true;
    description = "Ondřej Kučera";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
    thunderbird
    inkscape
    krita
    gimp2
    slack
    vscode
    cider-2
    element-desktop
    vicinae
    starship
    ];
  };
}