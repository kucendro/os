{ lib, pkgs, ... }:

let
  servers = {
    gitea = {
      package = pkgs.gitea-mcp-server;
      port = 8092;
      extraArgs = [
        "-H"
        "http://127.0.0.1:3001"
      ];
    };
  };
in
{
  systemd.services = lib.mapAttrs' (
    name: srv:
    lib.nameValuePair "mcp-${name}" {
      description = "MCP server (${name})";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      serviceConfig = {
        ExecStart = "${lib.getExe srv.package} -t http -p ${toString srv.port} ${lib.escapeShellArgs srv.extraArgs}";
        Environment = "HOME=/var/lib/mcp-${name}";
        Restart = "on-failure";

        DynamicUser = true;
        StateDirectory = "mcp-${name}";
        NoNewPrivileges = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateTmp = true;
        PrivateDevices = true;
        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
        ];
      };
    }
  ) servers;

  networking.firewall.interfaces."tailscale0".allowedTCPPorts = lib.mapAttrsToList (
    _: srv: srv.port
  ) servers;
}
