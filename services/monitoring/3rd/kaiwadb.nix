{ config, ... }:

{
  virtualisation.oci-containers = {
    backend = "docker";

    #: unit kaiwadb-tunnel
    #: -> nas/clickhouse sql
    containers.kaiwadb-tunnel = {
      image = "ghcr.io/kaiwadb/tunnel:0.11.0";
      environmentFiles = [ config.sops.templates."kaiwadb-tunnel-env".path ];
      cmd = [
        "--no-scan"
        "--log-format"
        "json"
      ];
      extraOptions = [ "--network=host" ];
    };
  };
}
