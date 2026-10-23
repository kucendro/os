{
  nixpkgs,
}:

system:

let
  pkgs = import nixpkgs {
    inherit system;
    config.allowUnfree = true;
  };
in
{
  default = pkgs.mkShell {
    packages = [
      pkgs.typst
      pkgs.tinymist
      pkgs.opentimestamps-client
      pkgs.just
      pkgs.nh
      pkgs.lefthook
      pkgs.nixfmt
    ];
    TYPST_FONT_PATHS = "${pkgs.corefonts}/share/fonts";
    shellHook = ''
      lefthook install
    '';

  };
}
