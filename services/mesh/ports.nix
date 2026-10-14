{ config, lib, ... }:

let
  taken = lib.attrValues config.mesh.ports;
  clashes = lib.filterAttrs (_: port: lib.count (p: p == port) taken > 1) config.mesh.ports;
in
{
  options.mesh.ports = lib.mkOption {
    type = lib.types.attrsOf lib.types.port;
    default = { };
  };

  config.assertions = [
    {
      assertion = clashes == { };
      message = "mesh.ports clash: ${
        lib.concatStringsSep ", " (lib.mapAttrsToList (name: port: "${name}=${toString port}") clashes)
      }";
    }
  ];
}
