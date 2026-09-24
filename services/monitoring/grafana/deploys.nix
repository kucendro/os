{ ... }:

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
          {
            uid = "failed-units";
            title = "Failed units";
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
                  expr = ''node_systemd_unit_state{state="failed"} == 1'';
                  instant = true;
                  intervalMs = 1000;
                  legendFormat = "{{node}} {{name}}";
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
            dashboardUid = "deploys";
            panelId = 2;
            noDataState = "OK";
            execErrState = "Error";
            for = "5m";
            annotations = {
              __dashboardUid__ = "deploys";
              __panelId__ = "2";
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
