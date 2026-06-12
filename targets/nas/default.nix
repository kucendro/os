{ ... }:

{
  imports = [
    ../linux.nix
    ./disko.nix
    ./data.nix
    ../../services/dockerized/music-assistant.nix
    ../../services/immich.nix
  ];

  nixpkgs.hostPlatform = "x86_64-linux";
}
