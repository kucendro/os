{
  inputs,
  pkgs,
  me,
  ...
}:

let
  homeDomain = me.domains.home;
  tailnetIP = "100.64.0.1";
in
{
  imports = [ inputs.nixdiag.nixosModules.default ];

  #: wiki
  #: expose 443 mesh name=wiki@home
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
