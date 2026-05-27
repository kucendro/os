{
  pkgs,
  lib,
  config,
  me,
  profile,
  ...
}:

let
  sharedPackages = with pkgs; [
    starship
    nushell
    fd
    lsd
    tldr
    jq
    yq
    fzf
    ripgrep
    magic-wormhole
    just
    tokei
    taskwarrior3
    lefthook
    cloudflared
    opencode
    github-copilot-cli
    ollama
    kubectl
    sqlx-cli
    supabase-cli
    d2
    nmap
    maven
    javaPackages.compiler.openjdk25
    php
  ];

  desktopPackages = with pkgs; [
    inkscape
    krita
    slack
    vscode
    element-desktop
    orca-slicer
    prusa-slicer
    wireshark
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
    gnome-calendar
    gnome-calculator
    discord
    arduino-ide
    chromium
    google-chrome
    clickhouse
    mongodb-compass
    kdePackages.qttools
    kicad
    witr
    beeper
    setxkbmap
    postman
    obsidian
    kiwix
    lmms
    tableplus
    worktrunk
    mkchromecast
    qlcplus
    qalculate-gtk
  ];
in

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
    packages = sharedPackages ++ lib.optionals (profile == "desktop") desktopPackages;
  };
}
