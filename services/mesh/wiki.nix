{ pkgs, ... }:

let
  homeDomain = "home.kucendro.dev";
  tailnetIP = "100.64.0.1";

  site = pkgs.stdenv.mkDerivation {
    name = "kucendro-wiki";
    src = ../../docs/wiki;
    nativeBuildInputs = [ pkgs.mdbook ];
    dontConfigure = true;
    dontBuild = true;
    installPhase = ''
      export HOME=$TMPDIR
      mkdir -p $out
      mdbook build --dest-dir $out
    '';
  };
in
{
  services.nginx.virtualHosts."wiki.${homeDomain}" = {
    listenAddresses = [ tailnetIP ];
    useACMEHost = homeDomain;
    forceSSL = true;
    root = site;
  };
}
