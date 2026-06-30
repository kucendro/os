{ ... }:

{
  imports = [
    ../linux.nix
    ./disko.nix
    ./data.nix
    ../../services/mesh/subnet-router.nix
    ../../services/dockerized/music-assistant.nix
    ../../services/dockerized/home-assistant.nix
    ../../services/dockerized/frigate.nix
    ../../services/dockerized/qore.nix
    ../../services/dockerized/open-wearables.nix
    ../../services/immich.nix
    ../../services/vault.nix
    ../../services/share/server.nix
    ../../services/grafana.nix
    ../../services/gitea.nix
  ];

  nixpkgs.hostPlatform = "x86_64-linux";
}
