{ config, inputs, ... }:

{
  imports = [ inputs.portfolio.nixosModules.kucendro ];

  services.kucendro = {
    enable = true;
    github.tokenFile = config.sops.secrets.kucendro-github-token.path;
    live.user = "gitea-runner";
  };

  mesh.ports.portfolio = 80;
}
