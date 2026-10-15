{ me, ... }:

let
  port = 8222;
in
{
  services.vaultwarden = {
    enable = true;
    backupDir = "/var/backup/vaultwarden";
    config = {
      DOMAIN = "https://vault.${me.domains.home}";
      ROCKET_ADDRESS = "0.0.0.0";
      ROCKET_PORT = port;
      SIGNUPS_ALLOWED = false;
    };
  };

  nixdiag.units.vaultwarden.ports = [ port ];

  mesh.ports.vaultwarden = port;
}
