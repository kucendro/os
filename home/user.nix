{ pkgs, config, me, ... }:

{
  users.users.${me.name} = {
    isNormalUser = true;
    description = me.fullName;
    hashedPasswordFile = config.sops.secrets.password_hash.path;
    extraGroups = [
      "networkmanager"
      "wheel"
      "vboxusers"
      "docker"
      "dialout"
    ];
    packages = with pkgs; [
      inkscape
      krita
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
      google-chrome
      clickhouse
      mongodb-compass
      spotify
      opencode
      github-copilot-cli
      ollama
      kdePackages.qttools
      kicad
      witr
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
      fd
      lsd
      tldr
      taskwarrior3
      nushell
      kiwix
      lmms
      supabase-cli
      lefthook
      tableplus
      worktrunk
      mkchromecast
      jq
      kubectl
    ];
  };
}
