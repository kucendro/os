{ inputs, pkgs, ... }:

{
  imports = [
    ./global.nix
    ../services/vpn/deep.nix
  ];

  networking.hostName = "nixbook";
  networking.networkmanager.enable = true;
  networking.firewall.allowedTCPPorts = [ 9901 ];
  networking.firewall.allowedUDPPorts = [ 9901 ];

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

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
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

  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;
  powerManagement.enable = true;
  powerManagement.cpuFreqGovernor = "powersave";

  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = "lock";
    HandlePowerKey = "suspend";
    IdleAction = "suspend";
    IdleActionSec = "5min";
  };

  programs.hyprland.enable = true;
  programs.hyprland.xwayland.enable = true;

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd start-hyprland";
        user = "greeter";
      };
    };
  };

  environment.systemPackages = with pkgs; [
    inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
    nautilus
    loupe
    qdirstat
    gpu-screen-recorder
    brightnessctl
  ];

  programs.firefox.enable = true;
  programs.evince.enable = true;
  programs.kdeconnect.enable = true;

  virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = [ "kucendro" ];
  virtualisation.virtualbox.host.enableExtensionPack = true;
}
