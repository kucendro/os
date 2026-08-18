{ ... }:

{
  imports = [
    ../../base/linux.nix
    ../../profiles/aws.nix
    ../../profiles/workstation
  ];

  nixpkgs.hostPlatform = "x86_64-linux";
}
