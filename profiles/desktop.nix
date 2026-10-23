{ pkgs, me, ... }:

{
  imports = [
    ./graphical.nix
    ../display/plymouth.nix
    ../services/virtualization/win.nix
  ];

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Experimental = true;
        FastConnectable = false;
      };
      Policy = {
        AutoEnable = true;
      };
    };
  };

  services = {
    avahi = {
      enable = true;
      publish.enable = true;
      publish.userServices = true;
    };

    greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd start-hyprland";
          user = "greeter";
        };
      };
    };

    pipewire = {
      jack.enable = true;
      raopOpenFirewall = true;
      extraConfig.pipewire."91-raop-discover" = {
        "context.modules" = [
          {
            name = "libpipewire-module-raop-discover";
          }
        ];
      };
    };

    printing = {
      enable = true;
      browsed.enable = false;
    };

    gvfs.enable = true;
  };

  systemd = {
    services.fwupd-refresh.enable = true;
    timers.fwupd-refresh.enable = true;
  };

  programs = {
    firefox.enable = true;
    evince.enable = true;
    kdeconnect.enable = true;
  };

  virtualisation.waydroid.enable = true;

  users.users.${me.name}.packages = with pkgs; [
    slack
    vscode
    phpstorm
    orca-slicer
    bambu-studio
    prusa-slicer
    wireshark
    metasploit
    aircrack-ng
    hashcat
    foremost
    sqlmap
    lycheeslicer
    libreoffice-qt-fresh
    gnome-calculator
    discord
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
    drawy
    zoom-us
    sshfs
    android-tools
    zeal
  ];

  home-manager.users.${me.name}.imports = [
    ../home/desktop.nix
  ];
}
