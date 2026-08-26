# Serves the nixdiag-generated wiki (`packages.docs`) straight from the store:
# it ships atomically with every deploy of this host.
{ inputs, pkgs, ... }:

let
  homeDomain = "home.kucendro.dev";
  tailnetIP = "100.64.0.1";
in
{
  imports = [ inputs.nixdiag.nixosModules.default ];

  services.nixdiag.serve = {
    enable = true;
    docs = inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.docs;
    virtualHost = "wiki.${homeDomain}";
    virtualHostExtra = {
      listenAddresses = [ tailnetIP ];
      useACMEHost = homeDomain;
      forceSSL = true;
    };
  };
}
