{
  pkgs,
  me,
  ...
}:

{
  #: mesh-control
  #: expose 3478/udp public
  services.headscale = {
    enable = true;
    address = "127.0.0.1";
    port = 8080;
    settings = {
      server_url = "https://${me.domains.edge}";
      base_domain = me.domains.mesh;
      policy = {
        mode = "file";
        path = "${./acl.json}";
      };
      dns = {
        magic_dns = true;
        base_domain = me.domains.mesh;
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

  #: -> edge/headscale headscale :8080
  services.nginx.virtualHosts.${me.domains.edge} = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:8080";
      proxyWebsockets = true;
    };
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
