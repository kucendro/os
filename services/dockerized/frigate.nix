{ pkgs, ... }:

let
  port = 5000;

  configYaml = pkgs.writeText "frigate-config.yml" ''
    mqtt:
      enabled: false

    detectors:
      # CPU detection works out of the box. For a Coral TPU use `type: edgetpu`,
      # or `type: openvino` with an Intel iGPU (also uncomment the /dev/dri device
      # passthrough below) for far lower load.
      cpu1:
        type: cpu

    # Add cameras here, e.g.:
    # cameras:
    #   driveway:
    #     ffmpeg:
    #       inputs:
    #         - path: rtsp://user:pass@192.168.1.50:554/stream
    #           roles: [detect, record]
    #     detect:
    #       width: 1280
    #       height: 720
    #     record:
    #       enabled: true
    #       retain:
    #         days: 7
    cameras: {}
  '';
in
{
  virtualisation.oci-containers = {
    backend = "docker";

    containers.frigate = {
      image = "ghcr.io/blakeblackshear/frigate:stable";
      volumes = [
        "/mnt/data/frigate/config:/config"
        "/mnt/data/frigate/media:/media/frigate"
        "${configYaml}:/config/config.yml:ro"
        "/etc/localtime:/etc/localtime:ro"
      ];

      environment.TZ = "Europe/Prague";

      extraOptions = [
        "--network=host"
        "--shm-size=256m"
        "--mount=type=tmpfs,destination=/tmp/cache,tmpfs-size=1000000000"
        # "--device=/dev/dri/renderD128" # iGPU for hwaccel decode + openvino detect
      ];
    };
  };

  systemd.services.docker-frigate.unitConfig.RequiresMountsFor = [ "/mnt/data" ];

  systemd.tmpfiles.rules = [
    "d /mnt/data/frigate 0755 root root -"
    "d /mnt/data/frigate/config 0755 root root -"
    "d /mnt/data/frigate/media 0755 root root -"
  ];

  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [
    port
    8554 # RTSP restream (go2rtc)
    8555 # WebRTC live view
  ];
  networking.firewall.interfaces."tailscale0".allowedUDPPorts = [
    8555 # WebRTC live view
  ];
}
