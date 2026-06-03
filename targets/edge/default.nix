{ ... }:

{
  imports = [
    ../linux.nix
    ./disko.nix
    ../../services/nginx.nix
    ../../services/headscale.nix
    ../../services/beszel-hub.nix
  ];

  nixpkgs.hostPlatform = "x86_64-linux";
}
