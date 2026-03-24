{ config, ... }:

{
  security.acme = {
    acceptTerms = true;
    defaults = {
      email = config.sops.secrets."cloudflare-email".path;
      dnsProvider = "cloudflare";
      environmentFile = config.sops.templates."cloudflare-env".path;
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
      enableACME = true;
      forceSSL = true;

      locations."/" = {
        return = "200 'workstation ok'";
        extraConfig = ''
          default_type text/plain;
        '';
      };
    };

    # Example: add subservices like this in their own module files:
    #
    # services.nginx.virtualHosts."vllm.home.kucendro.dev" = {
    #   listenAddresses = [ "10.100.0.1" ];
    #   enableACME = true;
    #   forceSSL = true;
    #   locations."/" = {
    #     proxyPass = "http://127.0.0.1:8000";
    #     proxyWebsockets = true;
    #   };
    # };
  };

  networking.firewall.interfaces.wg0.allowedTCPPorts = [
    80
    443
  ];
}
