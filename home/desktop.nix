{
  pkgs,
  lib,
  inputs,
  ...
}:
{
  home.pointerCursor.enable = true;

  home.packages = [
    pkgs.sshfs
    pkgs.glib
  ];

  services = {
    kdeconnect = {
      enable = true;
      indicator = true;
    };

    kdeconnectRunCommands.commands = {
      "vol down" = "noctalia msg volume-down";
      "vol up" = "noctalia msg volume-up";
      "mute" = "noctalia msg volume-mute";
      "lock" = "hyprlock";
      "suspend" = "noctalia msg session lock-and-suspend";
    };

    udiskie = {
      enable = true;
      settings = {
        program_options = {
          file_manager = "${pkgs.nautilus}/bin/nautilus";
        };
      };
    };
  };

  programs = {
    noctalia = {
      enable = true;

      settings = {
        shell = {
          avatar_path = "${inputs.secrets}/profile.jpg";
          lang = "en";
          telemetry_enabled = false;
          clipboard_enabled = true;
          clipboard_auto_paste = "off";
          settings_show_advanced = true;

          panel = {
            launcher_placement = "floating";
            launcher_position = "center";
            control_center_placement = "attached";
            wallpaper_placement = "attached";
            session_placement = "attached";
          };

          launcher = {
            categories = true;
            show_icons = true;
            app_grid = true;
            sort_by_usage = true;
          };
        };

        wallpaper = {
          enabled = false;
          directory = "/home/kucendro/nixos/display/wallpapers";
          automation = {
            enabled = false;
            interval_seconds = 300;
            order = "alphabetical";
            recursive = true;
          };
        };

        backdrop.enabled = false;

        notification = {
          enable_daemon = true;
          show_app_name = true;
          show_actions = false;
          layer = "overlay";
        };

        osd = {
          position = "top_center";
        };

        lockscreen.enabled = false;

        idle.behavior = {
          lock = {
            enabled = false;
            timeout = 60;
            action = "lock";
          };
          "screen-off" = {
            enabled = false;
            timeout = 120;
            action = "screen_off";
          };
        };

        nightlight = {
          enabled = true;
          force = false;
          temperature_day = 5880;
          temperature_night = 4013;
        };

        location = {
          auto_locate = false;
          address = "Pardubice";
        };

        weather = {
          enabled = true;
          unit = "celsius";
          effects = true;
        };

        calendar.enabled = false;
        control_center.calendar = {
          show_events_card = true;
          show_week_numbers = false;
        };

        audio = {
          enable_overdrive = false;
          enable_sounds = false;
        };

        brightness.enable_ddcutil = true;

        system.monitor.enabled = true;

        dock.enabled = false;

        plugins = {
          enabled = [
            "icefish/phone-connect"
            "noctalia/bongocat"
          ];
          auto_update = true;
        };

        plugin_settings = {
          "icefish/phone-connect" = {
            device_alias = "Fold";
            custom_image = "/home/kucendro/nixos/display/fold.png";
            state_update_interval = 60;
          };
        };

        bar.main = {
          position = "top";
          auto_hide = false;
          reserve_space = true;

          start = [
            "control-center"
            "spacer"
            "active_window"
          ];
          center = [
            "workspaces"
            "spacer"
            "media"
            "spacer"
            "bar"
          ];
          end = [
            "cat"
            "spacer"
            "volume"
            "brightness"
            "network"
            "bluetooth"
            "battery"
            "tray"
            "spacer"
            "notifications"
          ];
        };

        widget = {
          active_window = {
            display = "icon_only";
            title_scroll = "on_hover";
          };

          workspaces = {
            show_labels = false;
            focused_output_only = true;
            hide_when_empty = false;
          };

          media = {
            artist_first = false;
            title_scroll = "on_hover";
            hide_when_no_media = true;
          };

          bar.type = "icefish/phone-connect:bar";

          cat = {
            type = "noctalia/bongocat:cat";
            audio_spectrum = true;
            tappy_mode = true;
          };

          volume = {
            show_label = false;
            actions.middle = "exec pwvucontrol";
          };
          brightness.show_label = false;
          network = {
            show_label = false;
            vpn_status = "both";
          };
          bluetooth.show_label = false;
          battery = {
            display_mode = "glyph";
            show_label = false;
          };
          tray.drawer = true;
          notifications.hide_when_no_unread = false;
        };
      };
    };

    chromium = {
      enable = true;
      commandLineArgs = [
        "--hide-crash-restore-bubble"
        "--restore-last-session"
      ];
    };

    kitty = lib.mkForce {
      enable = true;
      settings = {
        confirm_os_window_close = 0;
        dynamic_background_opacity = true;
        enable_audio_bell = false;
        mouse_hide_wait = "-1.0";
        background_blur = 5;
      };
    };
  };
}
