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
    cpuFreqGovernor = "powersave";
  };

  environment.systemPackages = with pkgs; [
    inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
    nautilus
    loupe
    qdirstat
    gpu-screen-recorder
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
    nix-ld.enable = true;
  };

  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc.lib
    zlib
    openssl
  ];

  # This shit doesnt work on latest linux, last supported 6.18
  # virtualisation.virtualbox = {
  #   host = {
  #     enable = true;
  #     enableExtensionPack = true;
  #   };
  #   # guest = {
  #   #   enable = true;
  #   #   dragAndDrop = true;
  #   # };
  # };

  users.extraGroups.vboxusers.members = [ me.name ];

}
