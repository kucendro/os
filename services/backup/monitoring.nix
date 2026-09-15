{
  config,
  lib,
  pkgs,
  me,
  ...
}:

let
  pushgateway = "http://edge.${me.domains.mesh}:9091/metrics/job/backup/target";

  backup-metrics = pkgs.writeShellApplication {
    name = "backup-metrics";
    runtimeInputs = [
      pkgs.curl
      pkgs.jq
    ];
    text = ''
      target="$1"
      case "$target" in
        local) unit=btrbk-data.service ;;
        hetzner) unit=restic-backups-hetzner.service ;;
        *) echo "unknown target $target" >&2; exit 1 ;;
      esac

      start="$(systemctl show "$unit" -p InactiveExitTimestampMonotonic --value)"
      end="$(systemctl show "$unit" -p InactiveEnterTimestampMonotonic --value)"
      duration=$(( (end - start) / 1000000 ))

      extra=""
      if [ "$target" = hetzner ]; then
        stats="$(/run/current-system/sw/bin/restic-hetzner stats --json --mode raw-data)"
        size="$(printf '%s' "$stats" | jq -r '.total_size')"
        count="$(printf '%s' "$stats" | jq -r '.snapshots_count')"
        extra="backup_repository_bytes{target=\"hetzner\"} $size"$'\n'"backup_snapshots{target=\"hetzner\"} $count"$'\n'
      fi

      {
        echo "backup_last_success_timestamp_seconds{target=\"$target\"} $(date +%s)"
        echo "backup_duration_seconds{target=\"$target\"} $duration"
        printf '%s' "$extra"
      } | curl -sf --data-binary @- -X PUT "${pushgateway}/$target"
    '';
  };

  telegram-notify = pkgs.writeShellApplication {
    name = "telegram-notify";
    runtimeInputs = [ pkgs.curl ];
    text = ''
      unit="$1"
      text="${config.networking.hostName}: $unit failed
      $(journalctl -u "$unit" -n 12 --no-pager -o cat)"
      curl -sf -X POST "https://api.telegram.org/bot$(cat ${config.sops.secrets.grafana-telegram-bottoken.path})/sendMessage" \
        --data-urlencode "chat_id=${toString me.telegram.chatId}" \
        --data-urlencode "text=$text" > /dev/null
    '';
  };
in
{
  systemd.services."backup-metrics@" = {
    description = "Push backup heartbeat for %i to the pushgateway";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${lib.getExe backup-metrics} %i";
    };
  };

  systemd.services."telegram-notify@" = {
    description = "Telegram message about failed unit %i";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${lib.getExe telegram-notify} %i";
    };
  };

  systemd.services.btrbk-data = {
    onSuccess = [ "backup-metrics@local.service" ];
    onFailure = [ "telegram-notify@%n.service" ];
  };

  systemd.services.restic-backups-hetzner = {
    onSuccess = [ "backup-metrics@hetzner.service" ];
    onFailure = [ "telegram-notify@%n.service" ];
  };

  services.grafana.provision = {
    dashboards.settings.providers = [
      {
        name = "backups";
        options.path = ./backup-dashboard.json;
      }
    ];
    alerting.rules.settings.groups = [
      {
        orgId = 1;
        name = "backups";
        folder = "backups";
        interval = "5m";
        rules = [
          {
            uid = "backups-stale";
            title = "Backups stale";
            condition = "C";
            data = [
              {
                refId = "A";
                relativeTimeRange = {
                  from = 600;
                  to = 0;
                };
                datasourceUid = "prometheus";
                model = {
                  editorMode = "code";
                  expr = lib.concatStringsSep " or " [
                    ''(time() - backup_last_success_timestamp_seconds{target="local"} > 3 * 3600)''
                    ''(time() - backup_last_success_timestamp_seconds{target="hetzner"} > 36 * 3600)''
                    ''absent(backup_last_success_timestamp_seconds{target="local"})''
                    ''absent(backup_last_success_timestamp_seconds{target="hetzner"})''
                  ];
                  instant = true;
                  intervalMs = 1000;
                  legendFormat = "{{target}}";
                  maxDataPoints = 43200;
                  range = false;
                  refId = "A";
                };
              }
              {
                refId = "C";
                queryType = "expression";
                relativeTimeRange = {
                  from = 0;
                  to = 0;
                };
                datasourceUid = "__expr__";
                model = {
                  conditions = [
                    {
                      evaluator = {
                        params = [ 0 ];
                        type = "gt";
                      };
                      operator.type = "and";
                      query.params = [ "C" ];
                      reducer = {
                        params = [ ];
                        type = "last";
                      };
                      type = "query";
                    }
                  ];
                  datasource = {
                    type = "__expr__";
                    uid = "__expr__";
                  };
                  expression = "A";
                  intervalMs = 1000;
                  maxDataPoints = 43200;
                  refId = "C";
                  type = "threshold";
                };
              }
            ];
            dashboardUid = "backups";
            panelId = 1;
            noDataState = "Alerting";
            execErrState = "Error";
            for = "30m";
            annotations = {
              __dashboardUid__ = "backups";
              __panelId__ = "1";
            };
            labels = { };
            isPaused = false;
            notification_settings.receiver = "Telegram bot";
          }
        ];
      }
    ];
  };
}
