{ pkgs, lib, ... }:

let
  webPort = 8888;
  playerName = "LedFx";
  configDir = "/var/lib/ledfx";
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

  #: unit ledfx
  systemd.services.ledfx = {
    description = "LedFx";
    wantedBy = [ "multi-user.target" ];
    after = [
      "network-online.target"
      "sound.target"
    ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      ExecStart = "${lib.getExe pkgs.ledfx} --offline --config ${configDir} --host 0.0.0.0 --port ${toString webPort}";
      DynamicUser = true;
      StateDirectory = "ledfx";
      SupplementaryGroups = [ "audio" ];
      Restart = "on-failure";
      RestartSec = 5;
    };
  };

  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ webPort ];
}
