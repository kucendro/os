{ ... }:

{
  imports = [
    ../../base/linux.nix
    ../../profiles/dev/host.nix
    ./disko.nix
    ./data.nix
    ./reliability.nix
    # ./tethering.nix
    ../../services/mesh/subnet-router.nix
    ../../services/smart-home
    ../../services/dockerized/qore.nix
    ../../services/open-webui.nix
    ../../services/kubicek.nix
    ../../services/immich.nix
    ../../services/vault.nix
    ../../services/sync/server.nix
    ../../services/monitoring/grafana
    ../../services/monitoring/endpoints.nix
    ../../services/monitoring/grafana/deploys.nix
    ../../services/monitoring/logs.nix
    ../../services/monitoring/grafana/home.nix
    ../../services/monitoring/clickhouse.nix
    ../../services/monitoring/collector.nix
    ../../services/monitoring/3rd/kaiwadb.nix
    ../../services/monitoring/3rd/telegram.nix
    ../../services/gitea.nix
    ../../services/cache.nix
    ../../services/mcp.nix
    ../../services/opencode.nix
    ../../services/karakeep.nix
    # ../../services/calibre-web.nix
    # ../../services/remarkable.nix
    ../../services/lazybaka.nix
    ../../services/portfolio.nix
    ../../services/backup
  ];

  nixpkgs.hostPlatform = "x86_64-linux";
}
