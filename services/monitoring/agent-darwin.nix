{ pkgs, ... }:

let
  envPath = "/etc/beszel-agent.env";
  launcher = pkgs.writeShellScript "beszel-agent-launcher" ''
    while IFS='=' read -r key value; do
      [ -z "$key" ] && continue
      export "$key=$value"
    done < ${envPath}
    exec ${pkgs.beszel}/bin/beszel-agent
  '';
in
{
  launchd.daemons.beszel-agent = {
    serviceConfig = {
      ProgramArguments = [ "${launcher}" ];
      KeepAlive = true;
      RunAtLoad = true;
      StandardErrorPath = "/var/log/beszel-agent.err";
      StandardOutPath = "/var/log/beszel-agent.out";
    };
  };
}
