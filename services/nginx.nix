{ config, me, ... }:

# Nginx + wildcard ACME for the home mesh.
#
# Bootstrap (one-time, when first deploying on workstation):
#   1. Create a Cloudflare API token with Zone:DNS:Edit + Zone:Zone:Read
#      scoped to kucendro.dev
#   2. `sops secrets/secrets.yaml` — add:
#        cloudflare-api-token: <token>
#   3. Uncomment the cloudflare-api-token secret line below.
#   4. nh os switch .#workstation — ACME requests the wildcard cert via DNS-01.

{
  # sops.secrets.cloudflare-api-token = { };

  # sops.templates."cloudflare-env".content = ''
  #   CF_DNS_API_TOKEN=${config.sops.placeholder.cloudflare-api-token}
  # '';

  security.acme = {
    acceptTerms = true;
    defaults = {
      email = me.emails.personal;
      dnsProvider = "cloudflare";
      # environmentFile = config.sops.templates."cloudflare-env".path;
    };

    # One wildcard cert; every vhost reuses it via useACMEHost.
    certs."home.kucendro.dev" = {
      domain = "home.kucendro.dev";
      extraDomainNames = [ "*.home.kucendro.dev" ];
    };
  };

  services.nginx = {
    enable = true;

    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    virtualHosts."home.kucendro.dev" = {
      default = true;
      listenAddresses = [ "10.100.0.1" ];
      useACMEHost = "home.kucendro.dev";
      forceSSL = true;

      locations."/" = {
        return = "200 'workstation ok'";
        extraConfig = ''
          default_type text/plain;
        '';
      };
    };
  };

  # Nginx only listens on the WG interface; only WG peers can reach it.
  networking.firewall.interfaces.wg0.allowedTCPPorts = [
    80
    443
  ];
}
