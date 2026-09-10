{
  nixpkgs,
  nixdiag,
  self,
  me,
  hostNames,
}:

system:

let
  pkgs = nixpkgs.legacyPackages.${system};
  lib = nixpkgs.lib;

  setups =
    file: prefix:
    lib.mapAttrs' (n: v: lib.nameValuePair "${prefix}-${n}" v) (
      import file {
        inherit lib me;
        hosts = hostNames;
      } pkgs
    );
in
setups ../services/phones/android/termux-setup.nix "termux-setup"
// setups ../services/phones/ios/blink-setup.nix "blink-setup"
// {
  phone-theme = import ../services/phones/theme.nix { inherit me; } pkgs;
}
// lib.optionalAttrs (system == "x86_64-linux") {
  workstation = import ../packages/workstation.nix {
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
    inherit me lib;
  };
  docs = import ./docs.nix {
    inherit
      nixdiag
      nixpkgs
      self
      me
      hostNames
      ;
  } system;
}
