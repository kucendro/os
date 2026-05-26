{ ... }:

{
  imports = [
    ../global.nix
    ./disko.nix
  ];

  nixpkgs.hostPlatform = "x86_64-linux";
}
