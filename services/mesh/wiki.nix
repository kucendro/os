{
  inputs,
  pkgs,
  me,
  ...
}:

{
  services.nixdiag.serve = {
    enable = true;
    docs = inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.docs;
    virtualHost = "wiki.${me.domains.home}";
    virtualHostExtra = {
      listenAddresses = [ "100.64.0.1" ];
      useACMEHost = me.domains.home;
      forceSSL = true;
    };
  };
}
