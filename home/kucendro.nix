{ config, pkgs, ... }:

{
  users.users.kucendro = {
    isNormalUser = true;
    description = "Ondřej Kučera";
    extraGroups = [
      "networkmanager"
      "wheel"
      "vboxusers"
      "docker"
    ];
    packages = with pkgs; [
      thunderbird
      inkscape
      krita
      gimp2
      slack
      vscode
      cider-2
      element-desktop
      starship
      orca-slicer
      prusa-slicer
      wireshark
      nmap
      metasploit
      aircrack-ng
      hashcat
      foremost
      sqlmap
      freecad
      LycheeSlicer
      libreoffice-qt-fresh
      wl-clipboard
      wtype
    ];
  };
}
