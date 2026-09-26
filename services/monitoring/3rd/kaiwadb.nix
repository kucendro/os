{ config, ... }:

{
  virtualisation.oci-containers = {
    backend = "docker";

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

  nixdiag.units.kaiwadb-tunnel.connections = [
    {
      to = "nas/clickhouse";
      label = "sql";
    }
  ];
}
