{ pkgs, ... }:

let
  port = 8123;
  reverseProxyIP = "100.64.0.1";
  lanInterface = "enp1s0";

  configYaml = pkgs.writeText "home-assistant-configuration.yaml" ''
    default_config:

    frontend:
      themes: !include_dir_merge_named themes

    http:
      use_x_forwarded_for: true
      trusted_proxies:
        - ${reverseProxyIP}

    automation: !include automations.yaml
    script: !include scripts.yaml
    scene: !include scenes.yaml
  '';
in
{
  virtualisation.oci-containers = {
    backend = "docker";

    #: unit home-assistant
    #: -> nas/matter-server matter :5580
    containers.home-assistant = {
      image = "ghcr.io/home-assistant/home-assistant:stable";
      volumes = [
        "/mnt/data/home-assistant:/config"
        "${configYaml}:/config/configuration.yaml:ro"
        "/run/dbus:/run/dbus:ro"
      ];

      environment.TZ = "Europe/Prague";

      extraOptions = [
        "--network=host"
      ];
    };

    #: unit matter-server
    containers.matter-server = {
      image = "ghcr.io/matter-js/matterjs-server:stable";
      volumes = [ "/mnt/data/matter-server:/data" ];

      environment = {
        TZ = "Europe/Prague";
        PRIMARY_INTERFACE = lanInterface;
      };

      extraOptions = [
        "--network=host"
        "--read-only"
      ];
    };
  };

  systemd.services.docker-home-assistant = {
    unitConfig.RequiresMountsFor = [ "/mnt/data" ];
    after = [ "docker-matter-server.service" ];
  };
  systemd.services.docker-matter-server.unitConfig.RequiresMountsFor = [ "/mnt/data" ];

  boot.kernelModules = [ "nf_conntrack" ];
  boot.kernel.sysctl."net.netfilter.nf_conntrack_udp_timeout_stream" = 3600;

  systemd.tmpfiles.rules = [
    "d /mnt/data/home-assistant 0700 root root -"
    "d /mnt/data/home-assistant/themes 0755 root root -"
    "f /mnt/data/home-assistant/automations.yaml 0644 root root - []"
    "f /mnt/data/home-assistant/scripts.yaml 0644 root root -"
    "f /mnt/data/home-assistant/scenes.yaml 0644 root root -"
    "d /mnt/data/matter-server 0700 1000 1000 -"
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
