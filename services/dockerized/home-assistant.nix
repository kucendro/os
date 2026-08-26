{ pkgs, ... }:

let
  port = 8123;
  reverseProxyIP = "100.64.0.1";

  configYaml = pkgs.writeText "home-assistant-configuration.yaml" ''
    # Loads default set of integrations. Do not remove.
    default_config:

    # Load frontend themes from the themes folder
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
  };

  systemd.services.docker-home-assistant.unitConfig.RequiresMountsFor = [ "/mnt/data" ];

  systemd.tmpfiles.rules = [
    "d /mnt/data/home-assistant 0700 root root -"
    "d /mnt/data/home-assistant/themes 0755 root root -"
    "f /mnt/data/home-assistant/automations.yaml 0644 root root - []"
    "f /mnt/data/home-assistant/scripts.yaml 0644 root root -"
    "f /mnt/data/home-assistant/scenes.yaml 0644 root root -"
  ];

  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ port ];

  networking.firewall.interfaces."enp1s0".allowedTCPPorts = [
    9999
    80
    443
  ];
  networking.firewall.interfaces."enp1s0".allowedUDPPorts = [
    9999
    20002
    1900
  ];
}
