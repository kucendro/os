{ pkgs, ... }:

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
      lycheeslicer
      libreoffice-qt-fresh
      wl-clipboard
      wtype
      yq
      gnome-calendar
      gnome-calculator
      cloudflared
      discord
      maven
      d2
      arduino-ide
      chromium
      clickhouse
      mongodb-compass
      spotify
      opencode
      kdePackages.qttools
      kicad
      witr
      androidenv.androidPkgs.androidsdk
      androidenv.androidPkgs.tools
      magic-wormhole
      just
      tokei
      beeper
      php
      setxkbmap
      postman
      maven
      javaPackages.compiler.openjdk25
      obsidian
      kubernetes
      fd
      lsd
      android-studio
      exo
      tldr
    ];
  };
}
