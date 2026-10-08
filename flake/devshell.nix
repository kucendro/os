{
  nixpkgs,
}:

system:

let
  pkgs = nixpkgs.legacyPackages.${system};
in
{
  default = pkgs.mkShell {
    packages = [
      pkgs.typst
      pkgs.opentimestamps-client
    ];
  };
}
