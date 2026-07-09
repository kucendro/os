{
  config,
  lib,
  pkgs,
  ...
}:

let
  prometheus = "http://nas.ts.kucendro.dev:9090";
  publicHost = "edge.kucendro.dev";
  webroot = "/var/www/metrics";
  gen = pkgs.writeShellApplication {
    name = "gen-metric-badges";
    runtimeInputs = [
      pkgs.curl
      pkgs.jq
      pkgs.coreutils
      pkgs.gnused
    ];
    text = ''
      set -euo pipefail
      out=${lib.escapeShellArg webroot}
      mkdir -p "$out"

      q() {
        curl -sf --max-time 10 "${prometheus}/api/v1/query" \
          --data-urlencode "query=$1" | jq -r '.data.result'
      }


      badge() {
        jq -n --arg l "$1" --arg m "$2" --arg c "$3" \
          '{schemaVersion:1,label:$l,message:$m,color:$c}' >"$out/$4.tmp"
        mv "$out/$4.tmp" "$out/$4"
      }

      up=$(q 'sum(probe_success)'   | jq -r '.[0].value[1] // "0"' | cut -d. -f1)
      total=$(q 'count(probe_success)' | jq -r '.[0].value[1] // "0"' | cut -d. -f1)

      color=red
      if [ "$total" != "0" ] && [ "$up" = "$total" ]; then
        color=brightgreen
      elif [ "$up" != "0" ]; then
        color=orange
      fi
      badge "services" "$up/$total up" "$color" "uptime.json"


      q 'probe_success' \
        | jq -r '.[] | "\(.metric.instance)\t\(.value[1])"' \
        | while IFS=$'\t' read -r inst val; do
            name=$(printf '%s' "$inst" \
              | sed -E 's#^https?://##; s#\.home\.kucendro\.dev/?$##; s#[^A-Za-z0-9_-]#_#g')
            if [ "''${val%%.*}" = "1" ]; then
              badge "$name" "up" "brightgreen" "svc_$name.json"
            else
              badge "$name" "down" "red" "svc_$name.json"
            fi
          done
    '';
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

  services.nginx.virtualHosts.${publicHost} = {
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
