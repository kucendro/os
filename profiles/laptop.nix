{ pkgs, me, ... }:

{
  imports = [
    ./desktop.nix
    ./dev.nix
  ];

  security.sudo.wheelNeedsPassword = true;

  services = {
    upower.enable = true;
    power-profiles-daemon.enable = true;
    openssh.openFirewall = false;
    tailscale = {
      useRoutingFeatures = "client";
      extraSetFlags = [ "--accept-routes" ];
    };

    logind.settings.Login = {
      HandleLidSwitch = "suspend";
      HandleLidSwitchExternalPower = "lock";
      HandlePowerKey = "suspend";
      IdleAction = "suspend";
      IdleActionSec = "5min";
    };
  };

  powerManagement.enable = true;

  environment.systemPackages = with pkgs; [
    brightnessctl
    geteduroam
  ];

  mesh.ports.ssh = 22;

  home-manager.users.${me.name} = {
    imports = [ ../home/hass-agent.nix ];

    services.hypridle.settings.listener = [
      {
        timeout = 150;
        on-timeout = "brightnessctl -s set 10";
        on-resume = "brightnessctl -r";
      }
    ];

    wayland.windowManager.hyprland.settings.bindel = [
      ",XF86MonBrightnessUp, exec, brightnessctl -e4 -n2 set 5%+"
      ",XF86MonBrightnessDown, exec, brightnessctl -e4 -n2 set 5%-"
    ];
  };
}
