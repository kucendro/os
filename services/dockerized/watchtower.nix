{ ... }:

{
  virtualisation.oci-containers = {
    backend = "docker";

    containers.watchtower = {
      image = "containrrr/watchtower:latest";
      volumes = [
        "/var/run/docker.sock:/var/run/docker.sock"
        "/etc/localtime:/etc/localtime:ro"
      ];

      environment = {
        TZ = "Europe/Prague";
        WATCHTOWER_CLEANUP = "true";
        WATCHTOWER_ROLLING_RESTART = "true";
        WATCHTOWER_SCHEDULE = "0 0 4 * * *";
      };

      labels."com.centurylinklabs.watchtower.enable" = "false";
    };
  };

  systemd.services.docker-watchtower.unitConfig.RequiresMountsFor = [ "/mnt/data" ];
}
