{
  config,
  lib,
  pkgs,
  ...
}:

let
  homeDomain = "home.kucendro.dev";
  endpoints = import ../mesh/proxied/endpoints.nix;
  targets = lib.mapAttrsToList (name: _: "https://${name}.${homeDomain}") endpoints;
  blackboxPort = 9115;
  prometheusPort = 9090;
in
{
  services.prometheus.exporters.blackbox = {
    enable = true;
    listenAddress = "127.0.0.1";
    port = blackboxPort;
    configFile = pkgs.writeText "blackbox.yml" (
      builtins.toJSON {
        modules.http_2xx = {
          prober = "http";
          timeout = "10s";
          http = {
            fail_if_not_ssl = true;
            preferred_ip_protocol = "ip4";
            follow_redirects = true;
            valid_status_codes = [
              200
              201
              204
              301
              302
              303
              307
              308
              401
              403
              404
            ];
          };
        };
      }
    );
  };

  services.prometheus = {
    enable = true;
    listenAddress = "0.0.0.0";
    port = prometheusPort;
    globalConfig.scrape_interval = "30s";

    scrapeConfigs = [
      {
        job_name = "blackbox-home";
        metrics_path = "/probe";
        params.module = [ "http_2xx" ];
        static_configs = [ { inherit targets; } ];
        relabel_configs = [
          {
            source_labels = [ "__address__" ];
            target_label = "__param_target";
          }
          {
            source_labels = [ "__param_target" ];
            target_label = "instance";
          }
          {
            target_label = "__address__";
            replacement = "127.0.0.1:${toString blackboxPort}";
          }
        ];
      }
      {
        job_name = "iperf3";
        honor_labels = true;
        static_configs = [ { targets = [ "edge.ts.kucendro.dev:9091" ]; } ];
      }
      {
        job_name = "containers";
        honor_labels = true;
        static_configs = [ { targets = [ "127.0.0.1:9091" ]; } ];
      }
    ];
  };

  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ prometheusPort ];

  services.grafana.provision = {
    enable = true;
    datasources.settings.datasources = [
      {
        name = "Prometheus";
        type = "prometheus";
        uid = "prometheus";
        access = "proxy";
        url = "http://127.0.0.1:${toString prometheusPort}";
        isDefault = true;
      }
    ];
    dashboards.settings.providers = [
      {
        name = "endpoints";
        options.path = ./blackbox-dashboard.json;
      }
      {
        name = "speed";
        options.path = ./iperf3-dashboard.json;
      }
      {
        name = "containers";
        options.path = ./containers-dashboard.json;
      }
    ];
    alerting.contactPoints.settings = {
      apiVersion = 1;
      contactPoints = [
        {
          orgId = 1;
          name = "Telegram bot";
          receivers = [
            {
              uid = "afr3gp4x53myoc";
              type = "telegram";
              settings = {
                bottoken = "$__file{${config.sops.secrets.grafana-telegram-bottoken.path}}";
                chatid = "8323605619";
                disable_notification = false;
                disable_web_page_preview = false;
                message = ''{{ template "telegram.default.message" . }}'';
                protect_content = false;
              };
              disableResolveMessage = true;
            }
          ];
        }
      ];
    };
    alerting.rules.settings = {
      apiVersion = 1;
      groups = [
        {
          orgId = 1;
          name = "endpoints";
          folder = "endpoints";
          interval = "1m";
          rules = [
            {
              uid = "ffr3i429c8c8wa";
              title = "Endpoints";
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
                    editorMode = "builder";
                    exemplar = false;
                    expr = "group by(instance) (probe_success == 0)";
                    instant = true;
                    intervalMs = 1000;
                    legendFormat = "__auto";
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
              dashboardUid = "home-endpoints";
              panelId = 2;
              noDataState = "NoData";
              execErrState = "Error";
              for = "1m";
              annotations = {
                __dashboardUid__ = "home-endpoints";
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
  };
}
