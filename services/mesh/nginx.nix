{ me, ... }:

{
  security.acme = {
    acceptTerms = true;
    defaults.email = me.emails.personal;
  };

  services.nginx = {
    enable = true;

    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
  };

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
}
