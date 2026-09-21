{ lib, pkgs, ... }:

let
  port = 8093;
in
{
  #: unit opencode
  #: expose 8093 mesh
  users.users.opencode = {
    isSystemUser = true;
    group = "opencode";
    home = "/var/lib/opencode";
  };
  users.groups.opencode = { };

  systemd.services.opencode = {
    description = "opencode headless server";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    unitConfig.RequiresMountsFor = [ "/var/lib/opencode" ];
    path = with pkgs; [
      bashInteractive
      git
      ripgrep
    ];
    environment = {
      HOME = "/var/lib/opencode";
      SHELL = lib.getExe pkgs.bashInteractive;
    };
    serviceConfig = {
      ExecStart = "${lib.getExe pkgs.opencode} serve --hostname 0.0.0.0 --port ${toString port} --print-logs";
      User = "opencode";
      Group = "opencode";
      WorkingDirectory = "/var/lib/opencode";
      Restart = "on-failure";
      NoNewPrivileges = true;
      PrivateTmp = true;
    };
  };

  systemd.tmpfiles.rules = [
    "d /mnt/data/opencode 0700 opencode opencode -"
  ];

  fileSystems."/var/lib/opencode" = {
    device = "/mnt/data/opencode";
    fsType = "none";
    options = [ "bind" ];
  };

  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ port ];
}
