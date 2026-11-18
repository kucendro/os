{
  config,
  lib,
  me,
  profile,
  ...
}:

let
  c = config.lib.stylix.colors;
  isStream = profile == "workstation";
  toLua = lib.generators.toLua { };

  autostart = [
    "LC_TIME=en_US.UTF-8 noctalia"
  ]
  ++ lib.optionals (!isStream) [
    "beeper & slack"
  ];

  allow =
    type: binaries:
    map (binary: {
      inherit binary type;
      mode = "allow";
    }) binaries;

  classes = names: "^(${lib.concatMapStringsSep "|" lib.escapeRegex names})$";
in
{
  wayland.windowManager.hyprland = {
    enable = true;
    configType = "lua";

    settings = {
      config = {
        xwayland.force_zero_scaling = true;

        ecosystem.enforce_permissions = true;

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

        animations.enabled = true;

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
          follow_mouse = 1;
          sensitivity = 0;
          touchpad = {
            natural_scroll = true;
            tap_to_click = true;
          };
        };
      };

      permission =
        allow "screencopy" [
          "/nix/store/.*/bin/grim"
          "/nix/store/.*/bin/slurp"
          "/nix/store/.*/bin/sunshine.*"
          "/nix/store/.*/bin/.*noctalia.*"
          "/nix/store/.*/libexec/xdg-desktop-portal-hyprland"
        ]
        ++ allow "plugin" [
          "/nix/store/.*/bin/hyprpm"
          "/nix/store/.*/bin/hyprctl"
        ];

      curve._args = [
        "ease"
        {
          type = "bezier";
          points = [
            [
              0.25
              0.1
            ]
            [
              0.25
              1
            ]
          ];
        }
      ];

      animation =
        map
          (
            anim:
            {
              enabled = true;
              speed = 2.5;
              bezier = "ease";
            }
            // anim
          )
          [
            { leaf = "global"; }
            {
              leaf = "windows";
              style = "slide top";
            }
            {
              leaf = "layers";
              style = "slide top";
            }
            {
              leaf = "workspaces";
              style = "slide";
            }
          ];

      gesture =
        map
          (direction: {
            fingers = 3;
            inherit direction;
            action = "workspace";
          })
          [
            "horizontal"
            "vertical"
          ];

      window_rule = [
        {
          name = "suppress-maximize-events";
          match.class = ".*";
          suppress_event = "maximize minimize";
        }
        {
          name = "fix-xwayland-drags";
          match = {
            class = "^$";
            title = "^$";
            xwayland = true;
            float = true;
            fullscreen = false;
            pin = false;
          };
          no_focus = true;
        }
        {
          name = "apple-music-to-special";
          match.class = "^(Apple music|apple music).*$";
          workspace = "special:magic silent";
          opacity = "1";
        }
        {
          name = "float-apps";
          match.class = classes [
            "slack"
            "Beeper"
            "org.telegram.desktop"
            "org.gnome.Nautilus"
          ];
          float = true;
          center = true;
          size = "70% 80%";
        }
        {
          name = "float-apps-native-size";
          match.class = classes [
            "scrcpy"
            "Emulator"
            "org.gnome.Calculator"
          ];
          float = true;
          center = true;
        }
        {
          name = "slack-no-initial-focus";
          match.class = "^slack$";
          no_initial_focus = true;
        }
        {
          name = "float-dialogs";
          match = {
            class = "^$";
            title = "^$";
          };
          float = true;
          center = true;
        }
        {
          name = "move-hyprland-run";
          match.class = "hyprland-run";
          move = "20 monitor_h-120";
          float = true;
        }
        {
          name = "float-netreg";
          match = {
            class = "^(netreg\\.exe)$";
            title = "^(NetReg - .*)$";
          };
          float = true;
          center = true;
          size = "75% 80%";
        }
      ];
    };

    extraConfig = ''
      ${
        if isStream then
          ''hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })''
        else
          ''pcall(require, "monitors")''
      }

      hl.on("hyprland.start", function()
      ${lib.concatMapStrings (cmd: "  hl.exec_cmd(${toLua cmd})\n") autostart}end)

      hl.bind("SUPER_L", hl.dsp.exec_cmd("noctalia msg panel-toggle launcher"), { release = true })
      hl.bind("SUPER + A", hl.dsp.exec_cmd("noctalia msg panel-toggle control-center"))
      hl.bind("SUPER + L", hl.dsp.exec_cmd("noctalia msg session lock"))
      hl.bind("SUPER + V", hl.dsp.exec_cmd("noctalia msg panel-toggle clipboard"))
      hl.bind("SUPER + S", hl.dsp.exec_cmd('grim -g "$(slurp)" "$HOME/screenshots/$(date +%Y-%m-%d_%H-%M-%S).png"'))
      hl.bind("SUPER + period", hl.dsp.exec_cmd("rofimoji --selector fuzzel --action type --typer wtype"))

      for _, dir in ipairs({ "left", "right", "up", "down" }) do
        hl.bind("SUPER + " .. dir, hl.dsp.focus({ direction = dir }))
        hl.bind("SUPER + CTRL + " .. dir, hl.dsp.window.move({ direction = dir }))
      end
      hl.bind("SUPER + SHIFT + left", hl.dsp.window.resize({ x = -20, y = 0, relative = true }))
      hl.bind("SUPER + SHIFT + right", hl.dsp.window.resize({ x = 20, y = 0, relative = true }))
      hl.bind("SUPER + SHIFT + up", hl.dsp.window.resize({ x = 0, y = -20, relative = true }))
      hl.bind("SUPER + SHIFT + down", hl.dsp.window.resize({ x = 0, y = 20, relative = true }))

      hl.bind("SUPER + P", hl.dsp.window.pseudo())
      hl.bind("SUPER + F", hl.dsp.window.float({ action = "toggle" }))
      hl.bind("SUPER + Q", hl.dsp.window.close())

      hl.bind("SUPER + TAB", hl.dsp.focus({ workspace = "e+1" }))
      hl.bind("SUPER + SHIFT + TAB", hl.dsp.window.move({ workspace = "e+1" }))
      hl.bind("SUPER + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
      hl.bind("SUPER + mouse_up", hl.dsp.focus({ workspace = "e-1" }))
      hl.bind("SUPER + W", hl.dsp.workspace.toggle_special("magic"))
      hl.bind("SUPER + SHIFT + W", hl.dsp.window.move({ workspace = "special:magic" }))
      hl.bind("SUPER + CTRL + W", hl.dsp.window.move({ workspace = 1 }))

      hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
      hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })

      hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
      hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true, repeating = true })
      hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true, repeating = true })
      hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true, repeating = true })
    '';
  };
}
