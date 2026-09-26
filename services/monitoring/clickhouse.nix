{ config, pkgs, ... }:

let
  dataDir = "/mnt/data/clickhouse";
  database = "monitoring";
  httpPort = 8124;
  reader = name: ''
    <${name}>
      <no_password/>
      <networks>
        <ip>127.0.0.1</ip>
        <ip>::1</ip>
      </networks>
      <profile>readonly</profile>
      <quota>default</quota>
      <grants>
        <query>GRANT SELECT ON ${database}.*</query>
      </grants>
    </${name}>
  '';
in
{
  services.clickhouse = {
    enable = true;
    serverConfig = {
      http_port = httpPort;
      max_server_memory_usage_to_ram_ratio = 0.3;
      mark_cache_size = 536870912;
      uncompressed_cache_size = 268435456;
      max_concurrent_queries = 20;
    };
    extraUsersConfig = ''
      <clickhouse>
        <profiles>
          <readonly>
            <readonly>2</readonly>
          </readonly>
        </profiles>
        <users>
          <collector>
            <no_password/>
            <networks>
              <ip>127.0.0.1</ip>
              <ip>::1</ip>
            </networks>
            <profile>default</profile>
            <quota>default</quota>
            <grants>
              <query>GRANT CREATE DATABASE ON ${database}.*</query>
              <query>GRANT ALL ON ${database}.*</query>
            </grants>
          </collector>
          ${reader "kaiwadb"}
          ${reader "grafana"}
        </users>
      </clickhouse>
    '';
  };

  nixdiag.units.clickhouse.connections = [
    {
      to = "nas/grafana";
      label = "sql";
    }
  ];

  systemd.services.clickhouse = {
    unitConfig.RequiresMountsFor = [ "/var/lib/clickhouse" ];
    restartTriggers = [
      (builtins.toJSON config.services.clickhouse.serverConfig)
      config.services.clickhouse.extraUsersConfig
    ];
  };

  systemd.tmpfiles.rules = [ "d ${dataDir} 0700 clickhouse clickhouse -" ];

  fileSystems."/var/lib/clickhouse" = {
    device = dataDir;
    fsType = "none";
    options = [ "bind" ];
  };

  services.grafana = {
    declarativePlugins = [ pkgs.grafanaPlugins.grafana-clickhouse-datasource ];
    provision.datasources.settings.datasources = [
      {
        name = "ClickHouse";
        type = "grafana-clickhouse-datasource";
        uid = "clickhouse";
        access = "proxy";
        jsonData = {
          host = "127.0.0.1";
          port = 9000;
          protocol = "native";
          username = "grafana";
          defaultDatabase = database;
          logs = {
            defaultDatabase = database;
            defaultTable = "otel_logs";
            otelEnabled = true;
          };
        };
      }
    ];
  };
}
