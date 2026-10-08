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
    virtualHost = "infra.${me.domains.root}";
    virtualHostExtra = {
      enableACME = true;
      forceSSL = true;
    };
  };
}
