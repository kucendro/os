{ config, inputs, ... }:

{
  imports = [ inputs.portfolio.nixosModules.kucendro ];

  #: unit nginx
  #: unit kucendro-github
  services.kucendro = {
    enable = true;
    github.tokenFile = config.sops.secrets.kucendro-github-token.path;
  };

  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ 80 ];
}
