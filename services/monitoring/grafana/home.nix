{ ... }:

{
  services.grafana = {
    settings.dashboards.default_home_dashboard_path = "${./dashboards/home.json}";
    provision.dashboards.settings.providers = [
      {
        name = "home";
        options.path = ./dashboards/home.json;
      }
    ];
  };
}
