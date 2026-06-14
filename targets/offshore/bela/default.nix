{ ... }:

{
  imports = [
    ../../linux.nix
  ];

  nixpkgs.hostPlatform = "x86_64-linux";
}
