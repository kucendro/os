{ config, inputs, ... }:

{
  imports = [ inputs.portfolio.nixosModules.kucendro ];

  services.kucendro = {
    enable = true;
    github.tokenFile = config.sops.secrets.kucendro-github-token.path;
    live.user = "gitea-runner";
  };

  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ 80 ];
}
