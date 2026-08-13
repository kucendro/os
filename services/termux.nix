{
  lib,
  pkgs,
  me,
  hostNames,
  ...
}:

{
  environment.systemPackages = lib.attrValues (
    import ./termux-setup.nix {
      inherit lib me;
      hosts = hostNames;
    } pkgs
  );
}
