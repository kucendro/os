{ ... }:
{
  imports = [
    ../graphical.nix
    ../dev.nix
    ./gpu.nix
    ./session.nix
    ../../services/sunshine.nix
  ];
}
