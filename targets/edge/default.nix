{ ... }:

{
  imports = [
    ../linux.nix
    ./disko.nix
    ../../services/mesh/nginx.nix
    ../../services/mesh/headscale.nix
    ../../services/mesh/party.nix
    ../../services/mesh/proxied/services.nix
    ../../services/mesh/wiki.nix
    ../../services/monitoring/hub.nix
    ../../services/monitoring/iperf3.nix
    ../../services/monitoring/badges.nix
  ];

  nixpkgs.hostPlatform = "x86_64-linux";
}
