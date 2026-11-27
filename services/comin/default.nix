{
  config,
  inputs,
  lib,
  me,
  pkgs,
  ...
}:

{
  imports = [ inputs.comin.nixosModules.comin ];

  services.comin = import ./settings.nix {
    inherit
      config
      inputs
      lib
      me
      pkgs
      ;
  };

  nixdiag.units.comin = { };

  mesh.ports.comin = config.services.comin.exporter.port;
}
