{ ... }:

{
  imports = [
    ../linux.nix
    ./disko.nix
    ../../services/music-assistant.nix
  ];

  nixpkgs.hostPlatform = "x86_64-linux";
}
