{ ... }:

{
  imports = [
    ../../base/linux.nix
    ./disko.nix
    ./data.nix
    ./reliability.nix
    ./tethering.nix
    ../../services/mesh/subnet-router.nix
    ../../services/smart-home
    ../../services/dockerized/qore.nix
    ../../services/open-webui.nix
    ../../services/kubicek.nix
    ../../services/immich.nix
    ../../services/vault.nix
    ../../services/sync/server.nix
    ../../services/grafana.nix
    ../../services/monitoring/blackbox.nix
    ../../services/gitea.nix
    ../../services/cache.nix
    ../../services/mcp.nix
    ../../services/karakeep.nix
    # ../../services/remarkable.nix
    ../../services/lazybaka.nix
    ../../services/backup/snapshots.nix
  ];

  nixpkgs.hostPlatform = "x86_64-linux";
}
