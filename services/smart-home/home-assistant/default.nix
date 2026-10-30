{ me, pkgs, ... }:

let
  port = 8123;
  reverseProxyIP = "100.64.0.1";
  lanInterface = "wlp2s0";
  configDir = "/mnt/data/home-assistant";
  hostname = "assistant.${me.domains.home}";
  publicHostname = "mcp.assistant.${me.domains.root}";
  # shared prefix of the attention sensor templates; sets ns.items
  attentionItems = builtins.readFile ./attention.jinja;
  bedroomLamps = [
    "light.kajplats_e27_ws_g95_clear_806lm"
    "light.ondrej_s_bedroom_right_bulb"
  ];
  lampsAt =
    brightness: kelvin:
    builtins.listToAttrs (
      map (entity: {
        name = entity;
        value = {
          state = "on";
          inherit brightness;
          color_temp_kelvin = kelvin;
        };
      }) bedroomLamps
    );
in
{
  services.home-assistant = {
    enable = true;
    inherit configDir;

    extraComponents = [
      "default_config"
      "analytics"
      "backup"
      "bluetooth"
      "co2signal"
      "dhcp"
      "ecovacs"
      "esphome"
      "go2rtc"
      "google"
      "immich"
      "matter"
      "mcp_server"
      "met"
      "mobile_app"
      "music_assistant"
      "otbr"
      "sun"
      "thread"
      "tplink"
      "webostv"
      "karakeep"
      "syncthing"
      "zeroconf"
    ];

    customLovelaceModules = with pkgs.home-assistant-custom-lovelace-modules; [
      mushroom
      card-mod
      horizon-card
      mini-graph-card
      battery-state-card
      navbar-card
    ];

    config = {
      homeassistant = {
        time_zone = null;
        internal_url = "https://${hostname}";
        external_url = "https://${publicHostname}";
      };
      default_config = { };
      frontend.themes = "!include_dir_merge_named themes";
      http = {
        use_x_forwarded_for = true;
        trusted_proxies = [ reverseProxyIP ];
        ip_ban_enabled = true;
        login_attempts_threshold = 5;
      };
      automation = "!include automations.yaml";
      script = "!include scripts.yaml";
      scene = "!include scenes.yaml";

      "scene manual" = [
        {
          name = "Bedroom relax";
          icon = "mdi:sofa-outline";
          entities = lampsAt 102 2200;
        }
        {
          name = "Bedroom focus";
          icon = "mdi:lightbulb-on";
          entities = lampsAt 255 4000;
        }
        {
          name = "Bedroom night";
          icon = "mdi:weather-night";
          entities = {
            "light.kajplats_e27_ws_g95_clear_806lm" = {
              state = "on";
              brightness = 8;
              color_temp_kelvin = 2200;
            };
            "light.ondrej_s_bedroom_right_bulb".state = "off";
          };
        }
      ];

      template = [
        {
          sensor = [
            {
              name = "Attention";
              unique_id = "attention_items";
              icon = "mdi:alert-circle-outline";
              state = attentionItems + "{{ ns.items | count }}";
              attributes.items = attentionItems + "{{ ns.items }}";
            }
          ];
        }
      ];
    };
  };

  nixdiag.units.home-assistant = {
    ports = [ port ];
    connections = [
      {
        to = "matterjs-server";
        label = "matter :5580";
      }
      {
        to = "openthread-border-router";
        label = "thread :8081";
      }
    ];
  };

  services.matterjs-server = {
    enable = true;
    extraArgs = [ "--ble-proxy" ];
  };

  systemd.services.matterjs-server.serviceConfig.ExecStartPre =
    "${pkgs.findutils}/bin/find -H %S/matterjs-server -maxdepth 2 ( -name matter.lock -o -name matter.pid ) -delete";

  systemd.services.home-assistant = {
    unitConfig.RequiresMountsFor = [ "/mnt/data" ];
    after = [ "matterjs-server.service" ];
  };

  boot.kernelModules = [
    "nf_conntrack"
    "cdc_acm"
  ];

  hardware.bluetooth.enable = true;
  boot.kernel.sysctl."net.netfilter.nf_conntrack_udp_timeout_stream" = 3600;

  systemd.tmpfiles.rules = [
    "d ${configDir} 0700 hass hass -"
    "d ${configDir}/themes 0755 hass hass -"
    "d ${configDir}/www 0755 hass hass -"
    # Blender-rendered floorplan layers, served at /local/floorplan/
    "L+ ${configDir}/www/floorplan - - - - ${./floorplan}"
    "f ${configDir}/automations.yaml 0644 hass hass - []"
    "f ${configDir}/scripts.yaml 0644 hass hass -"
    "f ${configDir}/scenes.yaml 0644 hass hass -"
    "Z ${configDir} - hass hass -"
  ];

  mesh.ports.home-assistant = port;

  networking.firewall.interfaces.${lanInterface}.allowedUDPPorts = [
    1900
    5353
  ];
}
