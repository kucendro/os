{ ... }:

let
  port = 3100;
  dataDir = "/mnt/data/loki";
in
{
  services.loki = {
    enable = true;
    inherit dataDir;
    configuration = {
      auth_enabled = false;
      analytics.reporting_enabled = false;

      server = {
        http_listen_address = "0.0.0.0";
        http_listen_port = port;
        grpc_listen_address = "127.0.0.1";
      };

      common = {
        path_prefix = dataDir;
        instance_addr = "127.0.0.1";
        replication_factor = 1;
        ring.kvstore.store = "inmemory";
        storage.filesystem = {
          chunks_directory = "${dataDir}/chunks";
          rules_directory = "${dataDir}/rules";
        };
      };

      schema_config.configs = [
        {
          from = "2025-01-01";
          store = "tsdb";
          object_store = "filesystem";
          schema = "v13";
          index = {
            prefix = "index_";
            period = "24h";
          };
        }
      ];

      limits_config = {
        retention_period = "30d";
        allow_structured_metadata = true;
      };

      compactor = {
        retention_enabled = true;
        delete_request_store = "filesystem";
      };
    };
  };

  nixdiag.units.loki.connections = [
    {
      to = "nas/grafana";
      label = "logs";
    }
  ];

  systemd.services.loki.unitConfig.RequiresMountsFor = [ "/mnt/data" ];
  systemd.tmpfiles.rules = [ "d ${dataDir} 0700 loki loki -" ];

  services.grafana.provision.datasources.settings.datasources = [
    {
      name = "Loki";
      type = "loki";
      uid = "loki";
      access = "proxy";
      url = "http://127.0.0.1:${toString port}";
    }
  ];

  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ port ];
}
