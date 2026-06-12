{ ... }:

{
  virtualisation.oci-containers = {
    backend = "docker";

    containers.music-assistant = {
      image = "ghcr.io/music-assistant/server:latest";
      volumes = [ "/var/lib/music-assistant:/data" ];

      environment.LOG_LEVEL = "info";

      extraOptions = [
        "--network=host"
        "--cap-add=SYS_ADMIN"
        "--cap-add=DAC_READ_SEARCH"
        "--security-opt=apparmor:unconfined"
      ];
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/music-assistant 0700 root root -"
  ];

  networking.firewall.allowedTCPPorts = [
    8095
    8097
    1780
    1704
    1705
  ];
}
