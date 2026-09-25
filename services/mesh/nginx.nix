{ config, me, ... }:

{
  security.acme = {
    acceptTerms = true;
    defaults.email = me.emails.personal;
  };

  security.acme.certs.${me.domains.home} = {
    domain = me.domains.home;
    extraDomainNames = [
      "*.${me.domains.home}"
      "*.dev.${me.domains.root}"
    ];
    dnsProvider = "cloudflare";
    environmentFile = config.sops.templates."acme-cloudflare-env".path;
    extraLegoFlags = [ "--dns.propagation.disable-rns" ];
    group = "nginx";
  };

  #: proxy
  #: expose 443 public
  services.nginx = {
    enable = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    proxyTimeout = "600s";
  };

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];

  boot.kernel.sysctl."net.ipv4.ip_nonlocal_bind" = 1;
}
