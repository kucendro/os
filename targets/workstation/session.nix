{
  lib,
  pkgs,
  me,
  ...
}:

let
  # Minimal Hyprland for a stream-only box: no stylix / noctalia / desktop app
  # closure. This session exists to be captured by Sunshine, not looked at
  # locally, so keep it lean — that is what keeps cold-start fast. Sunshine's
  # global_prep_cmd (services/sunshine.nix) resizes the output at connect time.
  hyprConf = pkgs.writeText "hyprland-workstation.conf" ''
    monitor = ,preferred,auto,1

    exec-once = kitty

    misc {
      disable_hyprland_logo = true
      force_default_wallpaper = 0
    }

    input {
      kb_layout = ${me.keyboard.layout}
    }

    general {
      gaps_in = 4
      gaps_out = 8
      border_size = 1
    }

    $mod = SUPER
    bind = $mod, Return, exec, kitty
    bind = $mod, Q, killactive
    bind = $mod, F, fullscreen
  '';

  startSession = pkgs.writeShellApplication {
    name = "start-workstation-session";
    runtimeInputs = [ pkgs.hyprland ];
    text = ''
      # Wayland on NVIDIA. Unlike nixbook, NIXOS_OZONE_WL is safe to set here:
      # this box streams at an integer scale, so the eDP fractional-scale bug
      # that forces X11 on the laptop does not apply.
      export NIXOS_OZONE_WL=1
      export GBM_BACKEND=nvidia-drm
      export __GLX_VENDOR_LIBRARY_NAME=nvidia
      export WLR_NO_HARDWARE_CURSORS=1
      export XDG_SESSION_TYPE=wayland
      export XDG_CURRENT_DESKTOP=Hyprland
      exec Hyprland --config ${hyprConf}
    '';
  };
in
{
  programs.hyprland.enable = true;
  programs.hyprland.xwayland.enable = true;

  # Auto-login straight into the streamed session at boot; no greeter to wait on
  # a monitor that will never be attached.
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

  # It is a server: never sleep, so a dropped stream never lands you on a box
  # you cannot wake.
  services.logind.settings.Login = {
    HandleLidSwitch = "ignore";
    HandlePowerKey = "ignore";
    IdleAction = "ignore";
  };
  systemd.sleep.settings.Sleep = {
    AllowSuspend = "no";
    AllowHibernation = "no";
  };

  # Audio for the stream (Sunshine grabs a virtual sink).
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  environment.systemPackages = with pkgs; [
    kitty
    firefox
  ];
}
