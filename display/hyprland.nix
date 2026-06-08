{
  lib,
  pkgs,
  me,
  ...
}:

{

  services.kdeconnect = {
    enable = true;
    indicator = true;
  };

  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";
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

  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        hide_cursor = false;
        grace = 3;
        disable_loading_bar = true;
      };
      input-field = lib.mkForce [
        {
          fade_on_empty = true;
          hide_input = false;
          position = "0, -350";
          halign = "center";
          valign = "center";
          size = "0, 0";
          outer_color = "";
          inner_color = "";
        }
      ];
      label = lib.mkForce [
        {
          monitor = "";
          text = "$TIME";
          font_size = 60;
          position = "0, -200";
          halign = "center";
          valign = "center";
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

      source = [
        "$HOME/.config/hypr/monitors.conf"
        "$HOME/.config/hypr/workspaces.conf"
      ];

      exec-once = [
        "noctalia-shell"
        "beeper & slack"
      ];

      ecosystem.enforce_permissions = 1;

      permission = [
        "/nix/store/.*/bin/grim, screencopy, allow"
        "/nix/store/.*/bin/hyprlock, screencopy, allow"
        "/nix/store/.*/bin/slurp, screencopy, allow"
        "/nix/store/.*/bin/sunshine.*, screencopy, allow"
        "/nix/store/.*/libexec/xdg-desktop-portal-hyprland, screencopy, allow"
        "/nix/store/.*/bin/hyprpm, plugin, allow"
      ];

      general = {

        gaps_in = 5;
        gaps_out = 8;
        border_size = 0;
        resize_on_border = false;
        allow_tearing = false;
        layout = "dwindle";

      };

      decoration = {

        rounding = 12;
        rounding_power = 2;
        active_opacity = 1;
        inactive_opacity = 1;

        shadow = {
          enabled = true;
          range = 4;
          render_power = 3;
        };

        blur = {
          enabled = false;
        };

      };

      animations = {
        enabled = true;
        bezier = [
          "easeOutQuint,   0.23, 1,    0.32, 1"
          "easeInOutCubic, 0.65, 0.05, 0.36, 1"
          "linear,         0,    0,    1,    1"
          "almostLinear,   0.5,  0.5,  0.75, 1"
          "quick,          0.15, 0,    0.1,  1"
        ];
        animation = [
          "global,        1,     10,    default"
          "border,        1,     5.39,  easeOutQuint"
          "windows,       1,     4.79,  easeOutQuint"
          "windowsIn,     1,     4.1,   easeOutQuint, popin 87%"
          "windowsOut,    1,     1.49,  linear,       popin 87%"
          "fadeIn,        1,     1.73,  almostLinear"
          "fadeOut,       1,     1.46,  almostLinear"
          "fade,          1,     3.03,  quick"
          "layers,        1,     3.81,  easeOutQuint"
          "layersIn,      1,     4,     easeOutQuint, fade"
          "layersOut,     1,     1.5,   linear,       fade"
          "fadeLayersIn,  1,     1.79,  almostLinear"
          "fadeLayersOut, 1,     1.39,  almostLinear"
          "workspaces,    1,     1.94,  almostLinear, fade"
          "workspacesIn,  1,     1.21,  almostLinear, fade"
          "workspacesOut, 1,     1.94,  almostLinear, fade"
          "zoomFactor,    1,     7,     quick"
        ];
      };

      dwindle = {
        preserve_split = true;
        smart_split = true;
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

      bindr = "SUPER, SUPER_L, exec, noctalia-shell ipc call launcher toggle";

      bind = [
        "$mainMod, A, exec, noctalia-shell ipc call controlCenter toggle"
        "$mainMod, H, exec, noctalia-shell ipc call plugin:keybind-cheatsheet toggle"
        "$mainMod, L, exec, hyprlock"
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
        "$mainMod, S, exec, grim -g \"$(slurp)\""
        "$mainMod, F, togglefloating,"
        "$mainMod, Q, killactive,"
        "$mainMod, I, exec, ~/nixos/secrets/toggle-password.sh"
        "$mainMod, TAB, workspace, e+1"
        "$mainMod SHIFT, TAB, movetoworkspace, e+1"
        "$mainMod, W, togglespecialworkspace, magic"
        "$mainMod SHIFT, W, movetoworkspace, special:magic"
        "$mainMod CTRL, W, movetoworkspace, 1"
        "$mainMod, +, exec, tmux attach -d -t default"
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
    };

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
        match:class = ^(Beeper|beeper).*$
        workspace = special:magic silent
      }
      windowrule {
        name = slack-to-special
        match:class = ^(Slack|slack).*$
        workspace = special:magic silent
      }
      windowrule {
        name = kitty-opacity
        match:class = ^(Kitty|kitty).*$
        opacity = 0.95
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
    '';
  };
}
