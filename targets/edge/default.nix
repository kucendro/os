{ ... }:

{
  imports = [
    ../linux.nix
    ./disko.nix
    ../../services/nginx.nix
    ../../services/headscale.nix
  ];

  nixpkgs.hostPlatform = "x86_64-linux";
}
