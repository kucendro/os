{ lib, pkgs, ... }:
{
  home.packages = [ pkgs.go-hass-agent ];

  systemd.user.services.go-hass-agent = {
    Unit = {
      Description = "Go Hass Agent";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };

    Service = {
      ExecStart = "${lib.getExe pkgs.go-hass-agent} run --no-log-file";
      Restart = "on-failure";
      RestartSec = 30;
    };

    Install.WantedBy = [ "graphical-session.target" ];
  };
}
