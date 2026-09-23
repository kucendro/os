{ ... }:

{
  services.grafana = {
    settings.dashboards.default_home_dashboard_path = "${./home-dashboard.json}";
    provision.dashboards.settings.providers = [
      {
        name = "home";
        options.path = ./home-dashboard.json;
      }
    ];
  };
}
