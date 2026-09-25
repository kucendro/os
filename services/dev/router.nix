{ pkgs, me, ... }:

let
  port = 7000;
  dir = "/var/lib/dev";
in
{
  users.groups.dev.members = [ me.name ];

  systemd.tmpfiles.rules = [ "d ${dir} 2775 root dev -" ];

  #: expose 7000 mesh
  services.nginx = {
    enable = true;
    recommendedProxySettings = true;

    appendHttpConfig = ''
      map $host $dev_slug {
        ~^(?<slug>[a-z0-9-]+)\.dev\. $slug;
      }
      map $dev_slug $dev_port {
        include ${dir}/*.conf;
      }
    '';

    virtualHosts.dev = {
      serverName = "~^[a-z0-9-]+\\.dev\\.";
      listen = [
        {
          addr = "0.0.0.0";
          inherit port;
        }
      ];
      locations."/" = {
        proxyPass = "http://127.0.0.1:$dev_port";
        proxyWebsockets = true;
        extraConfig = ''
          if ($dev_port = "") {
            return 404;
          }
        '';
      };
    };
  };

  systemd.paths.dev-reload = {
    wantedBy = [ "multi-user.target" ];
    pathConfig.PathChanged = dir;
  };

  systemd.services.dev-reload = {
    serviceConfig.Type = "oneshot";
    script = "${pkgs.systemd}/bin/systemctl reload nginx.service";
  };

  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ port ];
}
