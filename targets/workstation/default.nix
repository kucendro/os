{ ... }:

{
  imports = [
    ../linux.nix
    ./disko.nix
    ./gpu.nix
    ./session.nix
    ../../services/sunshine.nix
  ];

  nixpkgs.hostPlatform = "x86_64-linux";
}
