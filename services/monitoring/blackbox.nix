{
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
    listenAddress = "127.0.0.1";
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
    ];
  };

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
    ];
  };
}
