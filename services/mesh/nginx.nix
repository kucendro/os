{ config, me, ... }:

{
  security.acme = {
    acceptTerms = true;
    defaults.email = me.emails.personal;
  };

  security.acme.certs.${me.domains.home} = {
    domain = me.domains.home;
    extraDomainNames = [ "*.${me.domains.home}" ];
    dnsProvider = "cloudflare";
    environmentFile = config.sops.templates."acme-cloudflare-env".path;
    group = "nginx";
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

  boot.kernel.sysctl."net.ipv4.ip_nonlocal_bind" = 1;
}
