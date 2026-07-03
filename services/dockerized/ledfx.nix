{ pkgs, ... }:

let
  webPort = 8888;
  playerName = "LedFx";
in
{
  boot.kernelModules = [ "snd-aloop" ];

  systemd.services.sendspin-ledfx = {
    description = "Sendspin player feeding LedFx via ALSA loopback";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      ExecStart = ''
        ${pkgs.python3Packages.sendspin}/bin/sendspin daemon \
          --name "${playerName}" \
          --audio-device Loopback \
          --audio-format flac:48000:16:2 \
          --settings-dir /var/lib/sendspin \
          --disable-mpris \
          --log-level INFO
      '';
      DynamicUser = true;
      StateDirectory = "sendspin";
      SupplementaryGroups = [ "audio" ];
      Restart = "on-failure";
      RestartSec = 5;
    };
  };

  virtualisation.oci-containers = {
    backend = "docker";

    containers.ledfx = {
      image = "ghcr.io/ledfx/ledfx:latest";
      volumes = [ "/var/lib/ledfx:/home/ledfx/ledfx-config" ];

      extraOptions = [
        "--network=host"
        "--device=/dev/snd"
      ];
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/ledfx 0755 1000 1000 -"
  ];

  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ webPort ];
}
