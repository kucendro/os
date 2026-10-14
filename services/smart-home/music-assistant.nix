{ ... }:

let
  port = 8095;
  streamPort = 8097;
  sendspinPort = 8927;
  ports = [
    port
    streamPort
    sendspinPort
  ];
in
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

  nixdiag.units.music-assistant.ports = ports;

  mesh.ports.music-assistant = port;

  systemd.tmpfiles.rules = [
    "d /var/lib/music-assistant 0700 root root -"
  ];

  networking.firewall.allowedTCPPorts = ports;

  networking.firewall.allowedUDPPorts = [ 5353 ];
}
