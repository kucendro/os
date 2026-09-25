{ ... }:
{
  imports = [
    ../graphical.nix
    ../dev
    ./gpu.nix
    ./session.nix
    ../../services/sunshine.nix
  ];
}
