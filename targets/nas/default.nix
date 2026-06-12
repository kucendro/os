{ ... }:

{
  imports = [
    ../linux.nix
    ./disko.nix
    ../../services/dockerized/music-assistant.nix
  ];

  nixpkgs.hostPlatform = "x86_64-linux";
}
