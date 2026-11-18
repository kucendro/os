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
    tailscale = {
      useRoutingFeatures = "client";
      extraSetFlags = [ "--accept-routes" ];
    };

    logind.settings.Login = {
      HandleLidSwitch = "suspend";
      HandleLidSwitchExternalPower = "lock";
      HandlePowerKey = "suspend";
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

    wayland.windowManager.hyprland.extraConfig = ''
      hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })
      hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeating = true })
    '';
  };
}
