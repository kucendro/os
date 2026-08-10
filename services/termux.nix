{
  lib,
  pkgs,
  me,
  ...
}:

{
  environment.systemPackages = lib.attrValues (import ./termux-setup.nix { inherit lib me; } pkgs);
}
