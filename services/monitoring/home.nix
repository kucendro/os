{ ... }:

{
  services.grafana = {
    settings.dashboards.default_home_dashboard_path = "${./grafana/dashboards/home.json}";
    provision.dashboards.settings.providers = [
      {
        name = "home";
        options.path = ./grafana/dashboards/home.json;
      }
    ];
  };
}
