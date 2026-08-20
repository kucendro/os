{
  inputs,
  pkgs,
  me,
  ...
}:

{
  imports = [
    ./graphical.nix
    ./dev.nix
    ../display/plymouth.nix
  ];

  security.sudo.wheelNeedsPassword = true;

  services.gnome.gnome-keyring.enable = true;
  security.pam.services.login.enableGnomeKeyring = true;

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

  security.rtkit.enable = true;
  security.pam.services.hyprlock = { };

  services = {

    upower.enable = true;
    power-profiles-daemon.enable = true;

    avahi = {
      enable = true;
      publish.enable = true;
      publish.userServices = true;
    };

    logind.settings.Login = {
      HandleLidSwitch = "suspend";
      HandleLidSwitchExternalPower = "lock";
      HandlePowerKey = "suspend";
      IdleAction = "suspend";
      IdleActionSec = "5min";
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
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
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

    pulseaudio.enable = false;
  };

  powerManagement = {
    enable = true;
  };

  environment.systemPackages = with pkgs; [
    inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
    # inputs.colibri.packages.${pkgs.stdenv.hostPlatform.system}.default
    nautilus
    loupe
    qdirstat
    gpu-screen-recorder
    moonlight-qt
    brightnessctl
    drawy
    gnome-network-displays
    nwg-displays
    adwaita-icon-theme
    gnome-keyring
    grim
    slurp
    hypridle
    clamav
    android-tools
    zoom-us
  ];

  environment.sessionVariables = {
    SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/gcr/ssh";
    NIXOS_OZONE_WL = "1";
    GDK_BACKEND = "wayland";
    XDG_SESSION_TYPE = "wayland";
    QT_QPA_PLATFORM = "wayland";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_DESKTOP = "Hyprland";
    COLI_MODEL = "/home/kucendro/ai";
  };

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  programs = {
    firefox.enable = true;
    evince.enable = true;
    kdeconnect.enable = true;
    dconf.enable = true;
    hyprland.enable = true;
    hyprland.xwayland.enable = true;
  };

  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc.lib
    zlib
    openssl
  ];

  home-manager.users.${me.name}.imports = [
    ../home/laptop.nix
  ];
}
