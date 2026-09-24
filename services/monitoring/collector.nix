{
  config,
  lib,
  pkgs,
  ...
}:

let
  otlpPort = 4318;
  ttl = "720h";
  stripNulls =
    v:
    if lib.isAttrs v then
      lib.mapAttrs (_: stripNulls) (lib.filterAttrs (n: x: n != "_module" && x != null) v)
    else if lib.isList v then
      map stripNulls v
    else
      v;
in
{
  #: unit opentelemetry-collector
  #: -> nas/clickhouse otel
  services.opentelemetry-collector = {
    enable = true;
    package = pkgs.opentelemetry-collector-contrib;
    settings = {
      receivers = {
        otlp.protocols.http.endpoint = "0.0.0.0:${toString otlpPort}";
        prometheus.config = {
          global.scrape_interval = "60s";
          scrape_configs = stripNulls config.services.prometheus.scrapeConfigs;
        };
      };
      processors = {
        groupbyattrs.keys = [
          "host"
          "unit"
        ];
        transform.log_statements = [
          {
            context = "resource";
            statements = [
              ''set(resource.attributes["service.name"], resource.attributes["unit"])''
              ''set(resource.attributes["host.name"], resource.attributes["host"])''
            ];
          }
          {
            context = "log";
            statements = [ ''set(log.severity_text, log.attributes["level"])'' ];
          }
        ];
        batch = {
          timeout = "10s";
          send_batch_size = 5000;
        };
      };
      exporters.clickhouse = {
        endpoint = "tcp://127.0.0.1:9000?dial_timeout=10s";
        username = "collector";
        database = "monitoring";
        create_schema = true;
        inherit ttl;
        async_insert = true;
        compress = "lz4";
      };
      service.pipelines = {
        logs = {
          receivers = [ "otlp" ];
          processors = [
            "groupbyattrs"
            "transform"
            "batch"
          ];
          exporters = [ "clickhouse" ];
        };
        metrics = {
          receivers = [ "prometheus" ];
          processors = [ "batch" ];
          exporters = [ "clickhouse" ];
        };
      };
    };
  };

  systemd.services.opentelemetry-collector = {
    after = [ "clickhouse.service" ];
    requires = [ "clickhouse.service" ];
    startLimitIntervalSec = 0;
    serviceConfig.RestartSec = 10;
  };

  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ otlpPort ];
}
