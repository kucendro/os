{
  config,
  inputs,
  flakeDir,
  lib,
  ...
}:
let
  lockOutputs = {
    "eDP-1" = {
      w = 1920;
      h = 1200;
    };
    "DP-1" = {
      w = 3440;
      h = 1440;
    };
  };

  lockWidgets = lib.concatMapAttrs (
    output:
    { w, h }:
    let
      s = h / 1200.0;
      place = cx: cy: bw: bh: {
        inherit output cx cy;
        box_width = bw;
        box_height = bh;
        rotation = 0.0;
        placement_width = w * 1.0;
        placement_height = h * 1.0;
      };
    in
    {
      "time@${output}" = place (w / 2.0) (h * 44 / 100.0) (480 * s) (160 * s) // {
        type = "clock";
        settings = {
          format = "{:%H:%M}";
          center_text = true;
          background = false;
        };
      };
      "date@${output}" = place (w / 2.0) (h * 56 / 100.0) (480 * s) (40 * s) // {
        type = "clock";
        settings = {
          format = "{:%A %d %B}";
          center_text = true;
          background = false;
          color = "on_surface_variant";
        };
      };
      "lockscreen-login-box@${output}" = place (w / 2.0) (h * 88 / 100.0) 400.0 70.0 // {
        type = "login_box";
        settings = {
          layout = "compact";
          background_opacity = 0.0;
          input_radius = 6.0;
          show_login_button = false;
          show_session_buttons = false;
          show_unlock_hint = false;
          show_media = false;
          show_weather = false;
          show_caps_lock = true;
          show_keyboard_layout = true;
        };
      };
    }
  ) lockOutputs;
in
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
        blur_intensity = 0.0;
        transition = [ "fade" ];
        transition_duration = 450;
        wallpaper = "${config.stylix.image}";
      };

      lockscreen_widgets = {
        enabled = true;
        schema_version = 2;
        widget_order = lib.attrNames lockWidgets;
        widget = lockWidgets;
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
          "felipeartur/ai-usagebar"
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
        hover_highlight = false;
        padding = 16;
        widget_spacing = 8;

        start = [
          "launcher"
          "gap"
          "workspaces"
          "gap"
          "active_window"
        ];
        center = [ "clock" ];
        end = [
          "media"
          "divider"
          "bar"
          "ai_usage"
          "tailnet"
          "syncthing"
          "bluetooth"
          "lidguard"
          "divider"
          "volume"
          "network"
          "battery"
          "divider"
          "notifications"
          "clipboard"
          "tray"
        ];
      };

      widget = {
        launcher.custom_image = "${./icon.png}";
        gap = {
          type = "spacer";
          length = 16;
        };

        workspaces = {
          show_labels = false;
          pill_scale = 0.5;
          focused_output_only = true;
          hide_when_empty = true;
          focused_color = "primary";
          occupied_color = "outline";
          empty_color = "outline";
        };

        active_window.display = "icon_only";

        clock = {
          format = "{:%H:%M}";
          tooltip_format = "{:%A %d %B}";
          font_weight = 500;
        };

        media = {
          album_art_only = true;
          hide_when_no_media = true;
        };

        divider = {
          type = "text";
          text = "│";
          color = "outline";
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
