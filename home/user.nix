{
  pkgs,
  lib,
  config,
  me,
  profile,
  ...
}:

let
  desktopPackages = with pkgs; [
    slack
    vscode
    orca-slicer
    prusa-slicer
    wireshark
    metasploit
    aircrack-ng
    hashcat
    foremost
    sqlmap
    lycheeslicer
    libreoffice-qt-fresh
    wl-clipboard
    wtype
    rofimoji
    fuzzel
    gnome-calculator
    discord
    (chromium.override { commandLineArgs = "--restore-last-session"; })
    google-chrome
    clickhouse
    kdePackages.qttools
    witr
    beeper
    setxkbmap
    obsidian
    kiwix
    lmms
    tableplus
    worktrunk
    mkchromecast
    qalculate-gtk
    hyprpicker
    tesseract
    zbar
    translate-shell
    wl-screenrec
    ffmpeg
    gifski
    (python3.withPackages (ps: [ ps.pygobject3 ]))
    qt6.qtwebsockets
    showtime
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
    packages = lib.optionals (profile == "desktop") desktopPackages;
  };
}
