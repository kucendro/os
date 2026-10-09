{
  config,
  inputs,
  flakeDir,
  ...
}:
{
  programs.noctalia = {
    enable = true;

    settings = {
      shell = {
        avatar_path = "${inputs.secrets}/profile.jpg";
        lang = "en";
        telemetry_enabled = false;
        clipboard_enabled = true;
        clipboard_auto_paste = "off";
        settings_show_advanced = true;
        corner_radius_scale = 0.25;

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
        directory = "${config.home.homeDirectory}/${flakeDir}/display/wallpapers";
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

      lockscreen = {
        enabled = true;
        allow_empty_password = true;
        blurred_desktop = false;
        wallpaper = "${config.stylix.image}";
      };

      idle.behavior = {
        lock = {
          enabled = true;
          timeout = 300;
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
        temperature_day = 5000;
        temperature_night = 4000;
      };

      location = {
        auto_locate = true;
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
          "felipeartur/ai-usagebar"
          "gabedunn/voxtype"
          "rylos/tailnet"
          "rylos/syncthing"
          "8bury/lid-guard"
          "dunarand/tmux-provider"
          "lowcache/claude-companion"
          "pozzoo/hassio"
        ];
        auto_update = "all";
      };

      plugin_settings = {
        "icefish/phone-connect" = {
          state_update_interval = 60;
          battery_display = "icon";
        };
      };

      bar.main = {
        position = "top";
        thickness = 32;
        auto_hide = false;
        reserve_space = true;
        margin_edge = 0;
        margin_ends = 0;
        radius = 0;
        background_opacity = 1.0;
        compositor_blur = false;
        shadow = false;
        padding = 16;
        widget_spacing = 8;

        start = [
          "workspaces"
          "active_window"
          "cat"
        ];
        center = [ "clock" ];
        end = [
          "media"
          "voxtype"
          "bar"
          "ai_usage"
          "tailnet"
          "syncthing"
          "bluetooth"
          "lidguard"
          "volume"
          "network"
          "battery"
          "notifications"
          "clipboard"
          "tray"
        ];
      };

      widget = {
        workspaces = {
          show_labels = false;
          focused_output_only = true;
          hide_when_empty = true;
          focused_color = "primary";
          occupied_color = "outline";
          empty_color = "outline";
        };

        active_window = {
          display = "icon_and_text";
          title_scroll = "on_hover";
        };

        clock = {
          format = "{:%H:%M}";
          tooltip_format = "{:%A %d %B}";
          font_weight = 500;
        };

        media = {
          album_art_only = false;
          hide_artist = true;
          title_scroll = "on_hover";
          hide_when_no_media = true;
        };

        cat = {
          type = "noctalia/bongocat:cat";
          audio_spectrum = true;
          tappy_mode = true;
        };
        voxtype = {
          type = "gabedunn/voxtype:status";
          idle_color = "outline";
        };
        bar.type = "icefish/phone-connect:bar";
        ai_usage = {
          type = "felipeartur/ai-usagebar:bar";
          visualization = "none";
          show_value = false;
          extras = "none";
        };
        tailnet = {
          type = "rylos/tailnet:bar";
          show_count = false;
          show_ip = false;
        };
        syncthing = {
          type = "rylos/syncthing:bar";
          show_pending = false;
        };
        bluetooth.show_label = false;
        lidguard.type = "8bury/lid-guard:lid-guard";
        volume = {
          show_label = false;
          actions.middle = "exec pwvucontrol";
        };
        network = {
          show_label = false;
          vpn_status = "both";
        };
        battery = {
          display_mode = "glyph";
          show_label = false;
        };
        notifications.hide_when_no_unread = true;
        tray.drawer = true;
      };
    };
  };
}
