{ ... }:

let
  httpPort = 3001;
  sshPort = 2222;
  webDomain = "git.home.kucendro.dev";
  sshDomain = "nas.ts.kucendro.dev";
in
{
  services.gitea = {
    enable = true;
    stateDir = "/mnt/data/gitea";
    database.type = "sqlite3";

    settings = {
      server = {
        DOMAIN = webDomain;
        ROOT_URL = "https://${webDomain}/";
        HTTP_ADDR = "0.0.0.0";
        HTTP_PORT = httpPort;
        START_SSH_SERVER = true;
        SSH_DOMAIN = sshDomain;
        SSH_PORT = sshPort;
        SSH_LISTEN_PORT = sshPort;
        BUILTIN_SSH_SERVER_USER = "git";
      };
      service.DISABLE_REGISTRATION = false;
    };
  };

  systemd.services.gitea.unitConfig.RequiresMountsFor = [ "/mnt/data" ];

  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [
    httpPort
    sshPort
  ];
}
