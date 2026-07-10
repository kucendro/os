{
  inputs,
  pkgs,
  me,
  ...
}:

{
  imports = [
    ../linux.nix
    ./zenbook.nix
    ../../services/vpn/deep.nix
    ../../services/kube.nix
    ../../services/sunshine.nix
    ../../services/scrcpy.nix
    ../../services/termux.nix
    ../../services/kdrive.nix
    ../../services/suuntool.nix
    ../../services/share/client.nix
  ];

  networking = {
    networkmanager.enable = true;
    firewall = {
      allowedTCPPorts = [
        9901
        443
      ];
      allowedUDPPorts = [
        9901
        1111
        2408
      ];
      allowedTCPPortRanges = [
        {
          from = 32768;
          to = 60999;
        }
      ];
      allowedUDPPortRanges = [
        {
          from = 32768;
          to = 60999;
        }
      ];
    };
  };

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

  hardware.printers = {
    # ensurePrinters = [
    #   {
    #     name = "DEEP";
    #     location = "work";
    #     deviceUri = "ipp://192.168.1.99/ipp/print";
    #     model = "everywhere";
    #     ppdOptions = {
    #       PageSize = "A4";
    #     };
    #   }
    # ];
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

    # Arduino serial adapters
    udev.extraRules = ''
      SUBSYSTEM=="tty", ATTRS{idVendor}=="1a86", ATTRS{idProduct}=="7523", GROUP="dialout", MODE="0660", ENV{ID_MM_DEVICE_IGNORE}="1"
      SUBSYSTEM=="tty", ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6001", GROUP="dialout", MODE="0660", ENV{ID_MM_DEVICE_IGNORE}="1"
      SUBSYSTEM=="tty", ATTRS{idVendor}=="10c4", ATTRS{idProduct}=="ea60", GROUP="dialout", MODE="0660", ENV{ID_MM_DEVICE_IGNORE}="1"
      SUBSYSTEM=="tty", ATTRS{idVendor}=="2341", GROUP="dialout", MODE="0660", ENV{ID_MM_DEVICE_IGNORE}="1"
    '';
  };

  powerManagement = {
    enable = true;
  };

  environment.systemPackages = with pkgs; [
    inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
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

  # TODO: This shit uncomment before start of last year of high school
  # virtualisation.virtualbox = {
  #   host = {
  #     enable = true;
  #     enableExtensionPack = true;
  #   };
  # };

  users.extraGroups.vboxusers.members = [ me.name ];

}
