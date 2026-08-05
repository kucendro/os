{
  pkgs,
  lib,
  ...
}:
{
  home.pointerCursor.enable = true;

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
          avatar_path = "/home/kucendro/nixos/home/profile.jpg";
          lang = "en";
          telemetry_enabled = false;
          clipboard_enabled = true;
          clipboard_auto_paste = "off";
          settings_show_advanced = true;

          animation = {
            enabled = true;
            speed = 1.0;
          };

          shadow.direction = "down_right";

          panel = {
            transparency_mode = "soft";
            borders = false;
            shadow = false;
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

        theme = {
          # theme.mode / source / custom_palette are set by the stylix noctalia
          # target (driven by base16Scheme = carbonfox). Set only non-color keys here.
          pure_black_dark = false;
        };

        wallpaper = {
          enabled = false;
          fill_mode = "center";
          fill_color = "#000000";
          directory = "/home/kucendro/nixos/display/wallpapers";
          transition = [
            "fade"
            "wipe"
            "disc"
            "stripes"
            "zoom"
            "honeycomb"
          ];
          transition_duration = 1500;
          edge_smoothness = 0.05;
          automation = {
            enabled = false;
            interval_seconds = 300;
            order = "alphabetical";
            recursive = true;
          };
        };

        backdrop = {
          enabled = false;
          blur_intensity = 0.4;
          tint_intensity = 0.6;
        };

        notification = {
          enable_daemon = true;
          show_app_name = true;
          show_actions = true;
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
          sound_volume = 0.5;
        };

        brightness.enable_ddcutil = true;

        system.monitor.enabled = true;

        dock = {
          enabled = false;
          position = "bottom";
          auto_hide = true;
        };

        bar.main = {
          position = "top";
          background_opacity = 0.93;
          radius = 12;
          margin_edge = 4;
          margin_ends = 4;
          widget_spacing = 2;
          scale = 0.95;
          shadow = false;
          capsule = false;
          capsule_opacity = 0.5;
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
          ];
          end = [
            "spacer"
            "sysmon_cpu"
            "sysmon_temp"
            "sysmon_mem"
            "sysmon_swap"
            "sysmon_net_rx"
            "sysmon_net_tx"
            "spacer"
            "volume"
            "brightness"
            "network"
            "bluetooth"
            "battery"
            "tray"
            "notifications"
          ];
        };

        widget = {
          spacer.length = 20;

          active_window = {
            max_length = 200;
            display = "icon_only";
            title_scroll = "on_hover";
          };

          workspaces = {
            show_labels = false;
            focused_color = "primary";
            occupied_color = "secondary";
            empty_color = "secondary";
            focused_output_only = true;
            hide_when_empty = false;
          };

          media = {
            max_length = 300;
            artist_first = true;
            title_scroll = "on_hover";
            hide_when_no_media = true;
          };

          sysmon_cpu = {
            type = "sysmon";
            stat = "cpu_usage";
          };
          sysmon_temp = {
            type = "sysmon";
            stat = "cpu_temp";
          };
          sysmon_mem = {
            type = "sysmon";
            stat = "ram_pct";
          };
          sysmon_swap = {
            type = "sysmon";
            stat = "swap_pct";
          };
          sysmon_net_rx = {
            type = "sysmon";
            stat = "net_rx";
          };
          sysmon_net_tx = {
            type = "sysmon";
            stat = "net_tx";
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
            show_label = true;
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
