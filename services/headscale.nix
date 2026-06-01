{
  pkgs,
  me,
  ...
}:

{
  services.headscale = {
    enable = true;
    address = "127.0.0.1";
    port = 8080;
    settings = {
      server_url = "https://edge.kucendro.dev";
      base_domain = "ts.kucendro.dev";
      dns = {
        magic_dns = true;
        base_domain = "ts.kucendro.dev";
        nameservers.global = [
          "1.1.1.1"
          "9.9.9.9"
        ];
      };
      derp = {
        server = {
          enabled = true;
          region_id = 999;
          region_code = "edge";
          region_name = "Edge";
          stun_listen_addr = "0.0.0.0:3478";
        };
        urls = [ ];
      };
    };
  };

  services.nginx.virtualHosts."edge.kucendro.dev" = {
    enableACME = true;
    forceSSL = true;
    locations."/".proxyPass = "http://127.0.0.1:8080";
  };

  networking.firewall.allowedUDPPorts = [ 3478 ];

  systemd.services.headscale-init = {
    description = "Ensure headscale user exists";
    after = [ "headscale.service" ];
    requires = [ "headscale.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.bash}/bin/bash -c 'headscale users create ${me.name} || true'";
    };
  };
}
