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
          "pozzoo/hassio"
        ];
        auto_update = "all";
      };

      plugin_settings = {
        "icefish/phone-connect" = {
          state_update_interval = 60;
        };
      };

      bar.main = {
        position = "top";
        auto_hide = false;
        reserve_space = true;
        margin_edge = 8;
        margin_ends = 8;
        radius = 12;
        concave_edge_corners = false;
        background_opacity = 0.75;

        start = [
          "clock"
          "spacer"
          "active_window"
        ];
        center = [
          "workspaces"
          "spacer"
          "cat"
        ];

        end = [
          "media"
          "spacer"
          "bar"
          "divider"
          "ai_usage"
          "divider"
          "volume"
          "brightness"
          "network"
          "tailnet"
          "bluetooth"
          "battery"
          "tray"
          "divider"
          "voxtype"
          "syncthing"
          "hassio"
          "divider"
          "clipboard"
          "divider"
          "notifications"
        ];
      };

      widget = {
        active_window = {
          display = "icon_only";
          title_scroll = "on_hover";
          min_length = 14;
        };

        workspaces = {
          show_labels = false;
          focused_output_only = true;
          hide_when_empty = true;
        };

        media = {
          album_art_only = false;
          hide_artist = true;
          title_scroll = "on_hover";
          hide_when_no_media = true;
        };

        bar = {
          type = "icefish/phone-connect:bar";
          battery_display = "percentage";
        };

        cat = {
          type = "noctalia/bongocat:cat";
          audio_spectrum = true;
          tappy_mode = true;
        };

        ai_usage.type = "felipeartur/ai-usagebar:bar";

        volume = {
          show_label = false;
          actions.middle = "exec pwvucontrol";
        };
        brightness.show_label = false;
        network = {
          show_label = false;
          vpn_status = "both";
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
        hassio = {
          type = "pozzoo/hassio:status";
          show_entity_count = false;
        };
        voxtype.type = "gabedunn/voxtype:status";
        divider = {
          type = "text";
          text = "│";
          color = "outline";
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
}
