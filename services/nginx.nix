{ config, me, ... }:

let
  selfName = config.networking.hostName;
  selfIp = (import ./connection/peers.nix).hosts.${selfName}.ip;
in

# Nginx + wildcard ACME for the home mesh. Binds on the host's wg IP, so it's
# reachable only from wg peers. Whoever imports this module hosts the cert.
#
# Bootstrap (one-time, when first enabling on a host):
#   1. Create a Cloudflare API token with Zone:DNS:Edit + Zone:Zone:Read
#      scoped to kucendro.dev
#   2. `sops secrets/secrets.yaml` — add:
#        cloudflare-api-token: <token>
#   3. Uncomment the cloudflare-api-token secret + template below and the
#      environmentFile line in security.acme.defaults.
#   4. nh os switch .#<host>

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
      listenAddresses = [ selfIp ];
      useACMEHost = "home.kucendro.dev";
      forceSSL = true;

      locations."/" = {
        return = "200 '${selfName} ok'";
        extraConfig = ''
          default_type text/plain;
        '';
      };
    };
  };

  networking.firewall.interfaces.wg0.allowedTCPPorts = [
    80
    443
  ];
}
