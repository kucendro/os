{
  lib,
  pkgs,
  me,
  ...
}:

let
  webroot = "/var/www/metrics";
  gen = pkgs.writeShellApplication {
    name = "gen-metric-badges";
    runtimeInputs = [
      pkgs.curl
      pkgs.jq
      pkgs.coreutils
      pkgs.gnused
    ];
    runtimeEnv = {
      PROMETHEUS = "http://nas.${me.domains.mesh}:9090";
      OUT = webroot;
      HOME_DOMAIN = me.domains.home;
    };
    text = builtins.readFile ./gen.sh;
  };
in
{
  systemd.tmpfiles.rules = [ "d ${webroot} 0755 nginx nginx - -" ];

  systemd.services.metric-badges = {
    description = "Generate shields.io status badges from Prometheus";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      Type = "oneshot";
      User = "nginx";
      Group = "nginx";
      ExecStart = lib.getExe gen;
    };
  };

  systemd.timers.metric-badges = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "2min";
      OnCalendar = "*:0/2";
      Persistent = true;
    };
  };

  services.nginx.virtualHosts.${me.domains.edge} = {
    enableACME = true;
    forceSSL = true;
    locations."/metrics/" = {
      alias = "${webroot}/";
      extraConfig = ''
        default_type application/json;
        add_header Access-Control-Allow-Origin *;
        add_header Cache-Control "public, max-age=60";
        autoindex off;
      '';
    };
  };
}
