{
  nixdiag,
  nixpkgs,
  self,
  me,
  hostNames,
}:

system:

let
  pkgs = nixpkgs.legacyPackages.${system};
  lib = nixpkgs.lib;

  setups = import ../services/termux-setup.nix {
    inherit lib me;
    hosts = hostNames;
  } pkgs;

  termux = pkgs.runCommand "termux-docs" { } ''
    mkdir -p $out/termux
    printf '# Termux bootstrap\n\nScan into Termux; raw scripts live under termux/.\n\n' > $out/termux.md
    ${lib.concatStringsSep "\n" (
      lib.mapAttrsToList (phone: drv: ''
        ${drv}/bin/termux-setup-${phone} > $out/termux/${phone}.sh
        ${drv}/bin/termux-setup-${phone} --png $out/termux/${phone}.png
        printf '## %s\n\n![%s](termux/%s.png)\n\n' '${phone}' '${phone}' '${phone}' >> $out/termux.md
      '') setups
    )}
  '';
in

nixdiag.lib.mkDocs {
  inherit pkgs;
  flake = self;
  title = "kucendro infrastructure wiki";
  indexPage = ../wiki/index.md;
  bookToml = ../wiki/book.toml;
  extraPages.Termux = "${termux}/termux.md";
  extraAssets.termux = "${termux}/termux";
  domains = me.domains;

  closures = [
    "nas"
    "nixbook"
    "stockholm"
  ];
}
