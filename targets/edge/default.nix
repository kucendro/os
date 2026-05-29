{ ... }:

{
  imports = [
    ../linux.nix
    ./disko.nix
    ../../services/connection/wg.nix
    ../../services/nginx.nix
  ];

  nixpkgs.hostPlatform = "x86_64-linux";
}
