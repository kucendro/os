{ config, me, ... }:

{
  services.alloy.enable = true;

  nixdiag.units.alloy.connections = [
    {
      to = "nas/loki";
      label = "logs";
    }
    {
      to = "nas/opentelemetry-collector";
      label = "logs";
    }
  ];

  environment.etc."alloy/config.alloy".text = ''
    loki.source.journal "journal" {
      labels        = { host = "${config.networking.hostName}" }
      relabel_rules = loki.relabel.journal.rules
      forward_to    = [loki.write.nas.receiver, otelcol.receiver.loki.nas.receiver]
    }

    loki.relabel "journal" {
      forward_to = []

      rule {
        source_labels = ["__journal__systemd_unit"]
        target_label  = "unit"
      }

      rule {
        source_labels = ["__journal_priority_keyword"]
        target_label  = "level"
      }
    }

    loki.write "nas" {
      endpoint {
        url                 = "http://nas.${me.domains.mesh}:3100/loki/api/v1/push"
        max_backoff_period  = "5m"
        max_backoff_retries = 0
      }
    }

    otelcol.receiver.loki "nas" {
      output {
        logs = [otelcol.processor.batch.nas.input]
      }
    }

    otelcol.processor.batch "nas" {
      output {
        logs = [otelcol.exporter.otlphttp.nas.input]
      }
    }

    otelcol.exporter.otlphttp "nas" {
      client {
        endpoint = "http://nas.${me.domains.mesh}:4318"
      }
    }
  '';
}
