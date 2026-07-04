{
  pkgs,
  lib,
  ...
}:

let
  pushgatewayPort = 9091;
  duration = 5;

  targets = {
    nas = "nas.ts.kucendro.dev";
    nixbook = "nixbook.ts.kucendro.dev";
    mac = "mac.ts.kucendro.dev";
  };

  targetLines = lib.concatStringsSep "\n" (
    lib.mapAttrsToList (name: host: ''["${name}"]="${host}"'') targets
  );

  iperf3-run = pkgs.writeShellApplication {
    name = "iperf3-run";
    runtimeInputs = [
      pkgs.iperf3
      pkgs.jq
      pkgs.curl
    ];
    text = ''
      declare -A targets=(
      ${targetLines}
      )

      bw=""
      up=""

      for name in "''${!targets[@]}"; do
        host="''${targets[$name]}"
        ok=1
        for dir in tx rx; do

          flag=""
          [ "$dir" = "rx" ] && flag="-R"

          if json="$(iperf3 -c "$host" -t ${toString duration} --connect-timeout 3000 -J $flag 2>/dev/null)"; then
            bps="$(printf '%s' "$json" | jq -r '.end.sum_received.bits_per_second // empty')"
            if [ -n "$bps" ]; then
              bw+="iperf3_bandwidth_bits_per_second{target=\"$name\",direction=\"$dir\"} $bps"$'\n'
            else
              ok=0
            fi
          else
            ok=0
          fi
        done
        up+="iperf3_up{target=\"$name\"} $ok"$'\n'
      done

      {
        echo "# HELP iperf3_bandwidth_bits_per_second Last iperf3 throughput per target and direction"
        echo "# TYPE iperf3_bandwidth_bits_per_second gauge"
        printf '%s' "$bw"
        echo "# HELP iperf3_up Whether the last iperf3 test to the target succeeded"
        echo "# TYPE iperf3_up gauge"
        printf '%s' "$up"
      } | curl -sf --data-binary @- -X PUT \
        "http://127.0.0.1:${toString pushgatewayPort}/metrics/job/iperf3"
    '';
  };
in
{
  services.prometheus.pushgateway.enable = true;

  systemd.services.iperf3-run = {
    description = "Run iperf3 speed tests against mesh targets, push to pushgateway";
    after = [
      "network-online.target"
      "pushgateway.service"
    ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = lib.getExe iperf3-run;
      DynamicUser = true;
    };
  };

  systemd.timers.iperf3-run = {
    description = "Hourly iperf3 speed tests";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "hourly";
      Persistent = true;
      RandomizedDelaySec = "5m";
    };
  };

  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ pushgatewayPort ];
}
