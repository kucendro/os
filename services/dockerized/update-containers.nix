{
  config,
  pkgs,
  lib,
  ...
}:

let
  containers = config.virtualisation.oci-containers.containers;

  pushgatewayPort = 9091;

  imageEntries = lib.concatStringsSep "\n" (
    lib.mapAttrsToList (name: c: ''["${name}"]="${c.image}"'') containers
  );

  update-containers = pkgs.writeShellApplication {
    name = "update-containers";
    runtimeInputs = [
      pkgs.docker
      pkgs.systemd
      pkgs.coreutils
      pkgs.curl
    ];
    text = ''
      declare -A images=(
      ${imageEntries}
      )

      if [ "''${#images[@]}" -eq 0 ]; then
        echo "No containers defined."
        exit 0
      fi

      start="$(date +%s)"
      statedir="''${STATE_DIRECTORY:-/var/lib/update-containers}/last-change"
      mkdir -p "$statedir"

      checked=0
      changed_count=0
      failed_count=0

      # One accumulator per metric family: the Prometheus text format requires
      # every sample of a family to be contiguous, so we cannot interleave them.
      m_pull=""
      m_changed=""
      m_last=""

      for name in "''${!images[@]}"; do
        img="''${images[$name]}"
        checked=$((checked + 1))
        printf '\n==> %s (%s)\n' "$name" "$img"

        before="$(docker image inspect --format '{{.Id}}' "$img" 2>/dev/null || true)"

        if docker pull "$img"; then
          pull_ok=1
        else
          pull_ok=0
          failed_count=$((failed_count + 1))
          echo "  pull failed" >&2
        fi

        changed=0
        if [ "$pull_ok" -eq 1 ]; then
          after="$(docker image inspect --format '{{.Id}}' "$img" 2>/dev/null || true)"
          if [ -n "$after" ] && [ "$before" != "$after" ]; then
            changed=1
            changed_count=$((changed_count + 1))
            echo "  image pulled, restarting docker-$name"
            systemctl restart "docker-$name.service"
            printf '%s' "$start" > "$statedir/$name"
          else
            echo "  up to date"
          fi
        fi

        last_change="$(cat "$statedir/$name" 2>/dev/null || echo 0)"

        m_pull+="container_update_pull_success{container=\"$name\"} $pull_ok"$'\n'
        m_changed+="container_update_changed{container=\"$name\"} $changed"$'\n'
        m_last+="container_update_last_change_timestamp_seconds{container=\"$name\"} $last_change"$'\n'
      done

      if [ "$changed_count" -gt 0 ]; then
        printf '\nPruning superseded images...\n'
        docker image prune -f
      fi

      end="$(date +%s)"
      duration=$((end - start))
      run_success=1
      if [ "$failed_count" -gt 0 ]; then run_success=0; fi

      {
        echo "# HELP container_update_pull_success Whether the last image pull for the container succeeded"
        echo "# TYPE container_update_pull_success gauge"
        printf '%s' "$m_pull"
        echo "# HELP container_update_changed Whether the image changed (and container was restarted) in the last run"
        echo "# TYPE container_update_changed gauge"
        printf '%s' "$m_changed"
        echo "# HELP container_update_last_change_timestamp_seconds Unix time the container image last changed"
        echo "# TYPE container_update_last_change_timestamp_seconds gauge"
        printf '%s' "$m_last"
        echo "# HELP container_update_last_run_timestamp_seconds Unix time the last update run finished"
        echo "# TYPE container_update_last_run_timestamp_seconds gauge"
        echo "container_update_last_run_timestamp_seconds $end"
        echo "# HELP container_update_run_duration_seconds Wall-clock duration of the last update run"
        echo "# TYPE container_update_run_duration_seconds gauge"
        echo "container_update_run_duration_seconds $duration"
        echo "# HELP container_update_checked_count Containers checked in the last run"
        echo "# TYPE container_update_checked_count gauge"
        echo "container_update_checked_count $checked"
        echo "# HELP container_update_changed_count Containers updated in the last run"
        echo "# TYPE container_update_changed_count gauge"
        echo "container_update_changed_count $changed_count"
        echo "# HELP container_update_failed_count Image pulls that failed in the last run"
        echo "# TYPE container_update_failed_count gauge"
        echo "container_update_failed_count $failed_count"
        echo "# HELP container_update_run_success Whether the last run completed with no pull failures"
        echo "# TYPE container_update_run_success gauge"
        echo "container_update_run_success $run_success"
      } | curl -sf --data-binary @- -X PUT \
        "http://127.0.0.1:${toString pushgatewayPort}/metrics/job/update-containers" \
        || echo "  metrics push failed" >&2

      printf '\nDone. %s container(s) updated.\n' "$changed_count"
    '';
  };
in
{
  environment.systemPackages = [ update-containers ];

  services.prometheus.pushgateway.enable = true;

  systemd.services.update-containers = {
    description = "Pull newer images for containers";
    after = [
      "docker.service"
      "pushgateway.service"
    ];
    requires = [ "docker.service" ];
    wants = [ "pushgateway.service" ];
    unitConfig.RequiresMountsFor = [ "/mnt/data" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = lib.getExe update-containers;
      StateDirectory = "update-containers";
    };
  };

  systemd.timers.update-containers = {
    description = "Auto container image update";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*-*-* 04:00:00";
      Persistent = true;
      RandomizedDelaySec = "30m";
    };
  };
}
