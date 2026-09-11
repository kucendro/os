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

  setups =
    file:
    import file {
      inherit lib me;
      hosts = hostNames;
    } pkgs;

  theme = import ../services/phones/theme.nix { inherit me; } pkgs;

  termux = pkgs.runCommand "termux-docs" { } ''
    mkdir -p $out/termux
    printf '# Termux bootstrap\n\nScan into Termux; raw scripts live under termux/, theme and font under phone/.\n\n' > $out/termux.md
    ${lib.concatStringsSep "\n" (
      lib.mapAttrsToList (phone: drv: ''
        ${drv}/bin/termux-setup-${phone} > $out/termux/${phone}.sh
        ${drv}/bin/termux-setup-${phone} --png $out/termux/${phone}.png
        printf '## %s\n\n![%s](termux/%s.png)\n\n' '${phone}' '${phone}' '${phone}' >> $out/termux.md
      '') (setups ../services/phones/android/termux-setup.nix)
    )}
  '';

  blink = pkgs.runCommand "blink-docs" { } ''
    mkdir -p $out/blink
    printf '# Blink bootstrap\n\nSsh config and snips live under blink/, theme and font under phone/.\n\n' > $out/blink.md
    ${lib.concatStringsSep "\n" (
      lib.mapAttrsToList (phone: drv: ''
        ${drv}/bin/blink-setup-${phone} --bundle $out/blink/${phone}
        ${drv}/bin/blink-setup-${phone} --png $out/blink/${phone}.png
        ${drv}/bin/blink-setup-${phone} --md >> $out/blink.md
      '') (setups ../services/phones/ios/blink-setup.nix)
    )}
  '';
in

nixdiag.lib.mkDocs {
  inherit pkgs;
  flake = self;
  title = "kucendro infrastructure wiki";
  indexPage = ../wiki/index.md;
  bookToml = ../wiki/book.toml;
  extraPages = {
    Termux = "${termux}/termux.md";
    Blink = "${blink}/blink.md";
    "Apt cache" = "${../wiki}/apt-cache.md";
  };
  extraAssets = {
    termux = "${termux}/termux";
    blink = "${blink}/blink";
    phone = "${theme}";
  };
  domains = me.domains;
  closures = true;
  closuresExclude = [ "edge" ];
}
