{ pkgs, ... }:

let
  port = 8123;
  reverseProxyIP = "100.64.0.1";
  lanInterface = "wlp2s0";
  configDir = "/mnt/data/home-assistant";
in
{
  #: -> nas/matterjs-server matter :5580
  #: -> nas/openthread-border-router thread :8081
  services.home-assistant = {
    enable = true;
    inherit configDir;

    extraComponents = [
      "default_config"
      "analytics"
      "backup"
      "co2signal"
      "dhcp"
      "ecovacs"
      "esphome"
      "go2rtc"
      "google_translate"
      "matter"
      "mcp_server"
      "met"
      "mobile_app"
      "music_assistant"
      "otbr"
      "radio_browser"
      "shopping_list"
      "sun"
      "thread"
      "tplink"
      "zeroconf"
    ];

    customLovelaceModules = with pkgs.home-assistant-custom-lovelace-modules; [
      mushroom
      card-mod
    ];

    config = {
      homeassistant.time_zone = null;
      default_config = { };
      frontend.themes = "!include_dir_merge_named themes";
      http = {
        use_x_forwarded_for = true;
        trusted_proxies = [ reverseProxyIP ];
      };
      automation = "!include automations.yaml";
      script = "!include scripts.yaml";
      scene = "!include scenes.yaml";
    };
  };

  services.matterjs-server.enable = true;

  systemd.services.home-assistant = {
    unitConfig.RequiresMountsFor = [ "/mnt/data" ];
    after = [ "matterjs-server.service" ];
  };

  boot.kernelModules = [ "nf_conntrack" ];
  boot.kernel.sysctl."net.netfilter.nf_conntrack_udp_timeout_stream" = 3600;

  systemd.tmpfiles.rules = [
    "d ${configDir} 0700 hass hass -"
    "d ${configDir}/themes 0755 hass hass -"
    "f ${configDir}/automations.yaml 0644 hass hass - []"
    "f ${configDir}/scripts.yaml 0644 hass hass -"
    "f ${configDir}/scenes.yaml 0644 hass hass -"
    "Z ${configDir} - hass hass -"
  ];

  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ port ];

  networking.firewall.interfaces.${lanInterface} = {
    allowedTCPPorts = [
      9999
      80
      443
    ];
    allowedUDPPorts = [
      9999
      20002
      1900
      5353
    ];
  };
}
