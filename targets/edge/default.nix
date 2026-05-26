{ ... }:

{
  imports = [
    ../global.nix
    ./disko.nix
    ../../services/connection/wg.nix
  ];

  nixpkgs.hostPlatform = "x86_64-linux";
}
