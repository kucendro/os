{
  config,
  pkgs,
  lib,
  ...
}:

let
  containers = config.virtualisation.oci-containers.containers;

  imageEntries = lib.concatStringsSep "\n" (
    lib.mapAttrsToList (name: c: ''["${name}"]="${c.image}"'') containers
  );

  update-containers = pkgs.writeShellApplication {
    name = "update-containers";
    runtimeInputs = [
      pkgs.docker
      pkgs.systemd
    ];
    text = ''
      declare -A images=(
      ${imageEntries}
      )

      if [ "''${#images[@]}" -eq 0 ]; then
        echo "No containers defined."
        exit 0
      fi

      updated=0
      for name in "''${!images[@]}"; do
        img="''${images[$name]}"
        printf '\n==> %s (%s)\n' "$name" "$img"

        before="$(docker image inspect --format '{{.Id}}' "$img" 2>/dev/null || true)"
        if ! docker pull "$img"; then
          echo "  pull failed" >&2
          continue
        fi
        after="$(docker image inspect --format '{{.Id}}' "$img")"

        if [ "$before" = "$after" ]; then
          echo "  up to date"
          continue
        fi

        echo "  image pulled, restarting docker-$name"
        systemctl restart "docker-$name.service"
        updated=$((updated + 1))
      done

      if [ "$updated" -gt 0 ]; then
        printf '\nPruning superseded images...\n'
        docker image prune -f
      fi

      printf '\nDone. %s container(s) updated.\n' "$updated"
    '';
  };
in
{
  environment.systemPackages = [ update-containers ];

  systemd.services.update-containers = {
    description = "Pull newer images for containers";
    after = [ "docker.service" ];
    requires = [ "docker.service" ];
    unitConfig.RequiresMountsFor = [ "/mnt/data" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = lib.getExe update-containers;
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
