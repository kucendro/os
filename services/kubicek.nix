{ pkgs, ... }:

let
  port = 3007;
  dir = "/home/kucendro/kubicek";
in
{
  systemd.services.kubicek = {
    description = "kubicek Next.js server";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    environment.NODE_ENV = "production";
    path = [ pkgs.nodejs_22 ];
    serviceConfig = {
      User = "kucendro";
      WorkingDirectory = dir;
      ExecStart = "${dir}/node_modules/.bin/next start -p ${toString port} -H 0.0.0.0";
      Restart = "on-failure";
      RestartSec = 5;
    };
  };

  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ port ];
}
