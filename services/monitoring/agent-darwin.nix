{ pkgs, ... }:

let
  envPath = "/etc/beszel-agent.env";
  launcher = pkgs.writeShellScript "beszel-agent-launcher" ''
    until [ -s ${envPath} ]; do sleep 2; done
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
      ThrottleInterval = 5;
      StandardErrorPath = "/var/log/beszel-agent.err";
      StandardOutPath = "/var/log/beszel-agent.out";
    };
  };

  system.activationScripts.postActivation.text = ''
    launchctl bootstrap system /Library/LaunchDaemons/org.nixos.beszel-agent.plist 2>/dev/null || true
  '';
}
