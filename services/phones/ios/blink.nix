{
  lib,
  pkgs,
  me,
  hostNames,
  ...
}:

{
  environment.systemPackages = lib.attrValues (
    import ./blink-setup.nix {
      inherit lib me;
      hosts = hostNames;
    } pkgs
  );
}
