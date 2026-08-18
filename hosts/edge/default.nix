{ ... }:

{
  imports = [
    ../../base/linux.nix
    ./disko.nix
    ../../services/mesh/nginx.nix
    ../../services/mesh/headscale.nix
    ../../services/mesh/public.nix
    ../../services/mesh/proxied/services.nix
    ../../services/mesh/wiki.nix
    ../../services/monitoring/hub.nix
    ../../services/monitoring/iperf3.nix
    ../../services/monitoring/badges.nix
  ];

  nixpkgs.hostPlatform = "x86_64-linux";
}
