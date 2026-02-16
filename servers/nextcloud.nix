{ config, pkgs, ... }:

{
  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud32;
    hostName = "cloud.kucendro.dev";
    config.adminpassFile = config.sops.secrets.nextcloud-admin-password.path;
    config.dbtype = "sqlite";
  };

}
