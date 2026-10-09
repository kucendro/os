{
  config,
  lib,
  pkgs,
  me,
  profile,
  ...
}:

let
  c = config.lib.stylix.colors;
  isStream = profile == "workstation";

  monitorConf =
    if isStream then
      { monitor = ",preferred,auto,1"; }
    else
      {
        source = [
          "$HOME/.config/hypr/monitors.conf"
          "$HOME/.config/hypr/workspaces.conf"
        ];
      };

  execOnce = [
    "LC_TIME=en_US.UTF-8 noctalia"
  ]
  ++ lib.optionals (!isStream) [
    "beeper & slack"
    # "env QT_QPA_PLATFORM=xcb kdrive"
  ];
in
{
  services.hypridle = {
    enable = !isStream;
    settings = {
      general = {
        lock_cmd = "noctalia msg session lock";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "hyprctl dispatch dpms on";
      };
      listener = [
        {
          timeout = 150;
          on-timeout = "brightnessctl -s set 10";
          on-resume = "brightnessctl -r";
        }
        {
          timeout = 300;
          on-timeout = "loginctl lock-session";
        }
        {
          timeout = 600;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
        {
          timeout = 1200;
          on-timeout = "systemctl suspend";
        }
      ];
    };
  };

  wayland.windowManager.hyprland = {
    enable = true;
    configType = "hyprlang";

    settings = {
      xwayland = {
        force_zero_scaling = true;
      };

      exec-once = execOnce;

      ecosystem.enforce_permissions = 1;

      permission = [
        "/nix/store/.*/bin/grim, screencopy, allow"
        "/nix/store/.*/bin/slurp, screencopy, allow"
        "/nix/store/.*/bin/sunshine.*, screencopy, allow"
        "/nix/store/.*/bin/.*noctalia.*, screencopy, allow"
        "/nix/store/.*/libexec/xdg-desktop-portal-hyprland, screencopy, allow"
        "/nix/store/.*/bin/hyprpm, plugin, allow"
        "/nix/store/.*/bin/hyprctl, plugin, allow"
      ];

      general = {
        gaps_in = 6;
        gaps_out = 12;
        border_size = 1;
        "col.active_border" = lib.mkForce "rgb(${c.base04})";
        "col.inactive_border" = lib.mkForce "rgb(${c.base02})";
        resize_on_border = false;
        allow_tearing = false;
        layout = "dwindle";
      };

      decoration = {
        rounding = 0;
        shadow.enabled = false;
        blur.enabled = false;
      };

      animations = {
        enabled = true;
        bezier = [ "ease, 0.25, 0.1, 0.25, 1" ];
        animation = [
          "global, 1, 2.5, ease"
          "windows, 1, 2.5, ease, slide top"
          "layers, 1, 2.5, ease, slide top"
          "workspaces, 1, 2.5, ease, slide"
        ];
      };

      dwindle = {
        preserve_split = true;
        smart_split = true;
        force_split = 2;
      };

      master.new_status = "master";

      misc = {
        force_default_wallpaper = 0;
        disable_hyprland_logo = true;
      };

      input = {
        kb_layout = me.keyboard.layout;
        kb_variant = ",qwerty";
        kb_model = "pc104";
        kb_options = "grp:alt_space_toggle";
        kb_rules = "";
        follow_mouse = 1;
        sensitivity = 0;
        touchpad = {
          natural_scroll = true;
          "tap-to-click" = true;
        };
      };

      gesture = [
        "3, horizontal, workspace"
        "3, vertical, workspace"
      ];

      "$mainMod" = "SUPER";

      bindr = [
        "SUPER, SUPER_L, exec, noctalia msg panel-toggle launcher"
      ];

      bind = [
        "$mainMod, A, exec, noctalia msg panel-toggle control-center"
        "$mainMod, L, exec, noctalia msg session lock"
        "$mainMod, V, exec, noctalia msg panel-toggle clipboard"
        "$mainMod, left, movefocus, l"
        "$mainMod, right, movefocus, r"
        "$mainMod, up, movefocus, u"
        "$mainMod, down, movefocus, d"
        "$mainMod CTRL, left, movewindow, l"
        "$mainMod CTRL, right, movewindow, r"
        "$mainMod CTRL, up, movewindow, u"
        "$mainMod CTRL, down, movewindow, d"
        "$mainMod SHIFT, left, resizeactive, -20 0"
        "$mainMod SHIFT, right, resizeactive, 20 0"
        "$mainMod SHIFT, up, resizeactive, 0 -20"
        "$mainMod SHIFT, down, resizeactive, 0 20"
        "$mainMod, P, pseudo,"
        "$mainMod, S, exec, grim -g \"$(slurp)\" \"$HOME/screenshots/$(date +%Y-%m-%d_%H-%M-%S).png\""
        "$mainMod, F, togglefloating,"
        "$mainMod, Q, killactive,"
        "$mainMod, TAB, workspace, e+1"
        "$mainMod SHIFT, TAB, movetoworkspace, e+1"
        "$mainMod, W, togglespecialworkspace, magic"
        "$mainMod SHIFT, W, movetoworkspace, special:magic"
        "$mainMod CTRL, W, movetoworkspace, 1"
        "$mainMod, +, exec, tmux attach -d -t default"
        "$mainMod, period, exec, rofimoji --selector fuzzel --action type --typer wtype"
        "$mainMod, mouse_down, workspace, e+1"
        "$mainMod, mouse_up, workspace, e-1"
      ];

      bindm = [
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
      ];

      bindel = [
        ",XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
        ",XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ",XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ",XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
        ",XF86MonBrightnessUp, exec, brightnessctl -e4 -n2 set 5%+"
        ",XF86MonBrightnessDown, exec, brightnessctl -e4 -n2 set 5%-"
      ];
    }
    // monitorConf;

    extraConfig = ''
      windowrule {
        name = suppress-maximize-events
        match:class = .*
        suppress_event = maximize, minimize
      }
      windowrule {
        name = fix-xwayland-drags
        match:class = ^$
        match:title = ^$
        match:xwayland = true
        match:float = true
        match:fullscreen = false
        match:pin = false
        no_focus = true
      }
      windowrule {
        name = apple-music-to-special
        match:class = ^(Apple music|apple music).*$
        workspace = special:magic silent
        opacity = 1
      }
      windowrule {
        name = beeper-to-special
        match:class = ^Beeper$
        workspace = special:magic silent
      }
      windowrule {
        name = float-slack
        match:class = ^slack$
        float = yes
        center = yes
        size = 70% 80%
        no_initial_focus = yes
      }
      windowrule {
        name = float-nautilus
        match:class = ^(org.gnome.Nautilus)$
        float = yes
        center = yes
        size = 60% 70%
      }
      windowrule {
        name = float-dialogs
        match:class = ^$
        match:title = ^$
        float = yes
        center = yes
      }
      windowrule {
        name = move-hyprland-run
        match:class = hyprland-run
        move = 20 monitor_h-120
        float = yes
      }
      windowrule {
        name = float-scrcpy
        match:class = ^(scrcpy)$
        float = yes
        center = yes
      }

      windowrule {
        name = float-simulator
        match:class = ^(Emulator)$
        float = yes
        center = yes
      }
      windowrule {
        name = float-netreg
        match:class = ^(netreg\.exe)$
        match:title = ^(NetReg - .*)$
        float = yes
        center = yes
        size = 75% 80%
      }
    '';
  };
}
