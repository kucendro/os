{ lib, ... }:

let
  alert =
    {
      uid,
      title,
      expr,
      legendFormat,
      for,
      panelId ? null,
    }:
    {
      inherit uid title for;
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
            inherit expr legendFormat;
            editorMode = "code";
            instant = true;
            intervalMs = 1000;
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
      noDataState = "OK";
      execErrState = "Error";
      labels = { };
      isPaused = false;
      notification_settings.receiver = "Telegram bot";
    }
    // lib.optionalAttrs (panelId != null) {
      inherit panelId;
      dashboardUid = "deploys";
      annotations = {
        __dashboardUid__ = "deploys";
        __panelId__ = toString panelId;
      };
    };
in
{
  services.grafana.provision = {
    dashboards.settings.providers = [
      {
        name = "deploys";
        options.path = ./dashboards/deploys.json;
      }
    ];
    alerting.rules.settings.groups = [
      {
        orgId = 1;
        name = "deploys";
        folder = "deploys";
        interval = "1m";
        rules = [
          (alert {
            uid = "failed-units";
            title = "Failed units";
            expr = ''node_systemd_unit_state{state="failed"} == 1'';
            legendFormat = "{{node}} {{name}}";
            for = "5m";
            panelId = 2;
          })
          (alert {
            uid = "deploy-failed";
            title = "Deploy failed";
            expr = "comin_last_eval_failed + comin_last_build_failed + comin_last_deployment_failed";
            legendFormat = "{{node}}";
            for = "1m";
          })
          (alert {
            uid = "deploy-stuck";
            title = "Deploy stuck";
            expr = ''
              (
                count by (node) (comin_deployment_info)
                unless on (node) (
                  label_replace(comin_deployment_info{status="done"}, "rev", "$1", "commit_id", "(.*)")
                  and on (rev) ci_run_info{workflow="deploy"}
                )
                unless on (node) (comin_last_eval_failed + comin_last_build_failed + comin_last_deployment_failed > 0)
              )
              and on () (ci_run_success{workflow="deploy"} == 1)
            '';
            legendFormat = "{{node}}";
            for = "30m";
          })
        ];
      }
    ];
  };
}
