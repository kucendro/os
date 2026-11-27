{
  config,
  inputs,
  lib,
  me,
  pkgs,
  ...
}:

{
  imports = [ inputs.comin.darwinModules.comin ];

  services.comin = lib.mkMerge [
    (import ./settings.nix {
      inherit
        config
        inputs
        lib
        me
        pkgs
        ;
    })
    { exporter.listen_address = "127.0.0.1"; }
  ];
}
