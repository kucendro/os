{
  lib,
  pkgs,
  me,
  ...
}:

let
  startSession = pkgs.writeShellApplication {
    name = "start-workstation-session";
    runtimeInputs = [ pkgs.hyprland ];
    text = ''
      export NIXOS_OZONE_WL=1
      export GBM_BACKEND=nvidia-drm
      export __GLX_VENDOR_LIBRARY_NAME=nvidia
      export WLR_NO_HARDWARE_CURSORS=1
      export XDG_SESSION_TYPE=wayland
      export XDG_CURRENT_DESKTOP=Hyprland
      exec Hyprland
    '';
  };
in
{
  programs.hyprland.enable = true;
  programs.hyprland.xwayland.enable = true;

  services.greetd = {
    enable = true;
    settings = {
      initial_session = {
        command = lib.getExe startSession;
        user = me.name;
      };
      default_session = {
        command = lib.getExe startSession;
        user = me.name;
      };
    };
  };

  services.logind.settings.Login = {
    HandleLidSwitch = "ignore";
    HandlePowerKey = "ignore";
    IdleAction = "ignore";
  };
  systemd.sleep.settings.Sleep = {
    AllowSuspend = "no";
    AllowHibernation = "no";
  };

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };
}
