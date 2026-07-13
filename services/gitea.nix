{ config, pkgs, lib, inputs, ... }:

let
  httpPort = 3001;
  sshPort = 2222;
  webDomain = "git.home.kucendro.dev";
  sshDomain = "nas.ts.kucendro.dev";
in
{
  services.gitea = {
    enable = true;
    lfs.enable = true;
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
      actions.ENABLED = true;
    };
  };

  services.gitea-actions-runner.instances.nas = {
    enable = true;
    name = "nas";
    url = "https://${webDomain}";
    tokenFile = config.sops.templates."gitea-runner-env".path;
    labels = [
      "native:host"
    ];

    hostPackages = with pkgs; [
      bash
      coreutils
      curl
      gawk
      gitMinimal
      gnused
      nodejs
      openssh
      wget
      config.nix.package
      inputs.deploy-rs.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
  };

  # Give the runner a stable identity + home so the sops-provisioned deploy
  # key lives at a predictable, owner-readable path (DynamicUser has no fixed
  # uid/home, which sops ownership and ~/.ssh both need).
  users.users.gitea-runner = {
    isSystemUser = true;
    group = "gitea-runner";
    home = "/var/lib/gitea-runner";
  };
  users.groups.gitea-runner = { };

  systemd.services.gitea-runner-nas.serviceConfig = {
    DynamicUser = lib.mkForce false;
    User = "gitea-runner";
    Group = "gitea-runner";
  };

  systemd.services.gitea.unitConfig.RequiresMountsFor = [ "/mnt/data" ];

  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [
    httpPort
    sshPort
  ];
}
