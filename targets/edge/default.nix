{ ... }:

{
  imports = [
    ../linux.nix
    ./disko.nix
    ../../services/mesh/nginx.nix
    ../../services/mesh/headscale.nix
    ../../services/monitoring/hub.nix
  ];

  nixpkgs.hostPlatform = "x86_64-linux";
}
