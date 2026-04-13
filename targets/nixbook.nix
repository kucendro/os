{ inputs, pkgs, ... }:

{
  imports = [
    ./global.nix
    ../services/vpn/deep.nix
  ];

  networking = {
    hostName = "nixbook";
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
      trustedInterfaces = [ "CloudflareWARP" ];
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

  services = {

    upower.enable = true;
    power-profiles-daemon.enable = true;

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
    wineWowPackages.staging
    winetricks
  ];

  programs = {
    firefox.enable = true;
    evince.enable = true;
    kdeconnect.enable = true;
    dconf.enable = true;
    hyprland.enable = true;
    hyprland.xwayland.enable = true;
  };

  virtualisation.virtualbox = {
    host = {
      enable = true;
      enableExtensionPack = true;
    };
    guest = {
      enable = true;
      dragAndDrop = true;
    };
  };
  users.extraGroups.vboxusers.members = [ "kucendro" ];

}
