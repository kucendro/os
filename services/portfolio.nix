{
  config,
  inputs,
  me,
  ...
}:

{
  imports = [ inputs.portfolio.nixosModules.kucendro ];

  services.kucendro = {
    enable = true;
    domain = me.domains.root;
    enableACME = true;
    github.tokenFile = config.sops.secrets.kucendro-github-token.path;
  };
}
