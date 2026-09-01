{
  config,
  pkgs,
  lib,
  inputs,
  me,
  ...
}:

let
  httpPort = 3001;
  sshPort = 2222;
  webDomain = "git.${me.domains.home}";
  sshDomain = "nas.${me.domains.mesh}";

  runnerService = {
    after = [ "gitea.service" ];
    preStart = ''
      for _ in $(seq 30); do
        ${lib.getExe pkgs.curl} -fsS -o /dev/null --max-time 2 "https://${webDomain}/api/healthz" && break
        sleep 1
      done
      :
    '';
    serviceConfig = {
      DynamicUser = lib.mkForce false;
      User = "gitea-runner";
      Group = "gitea-runner";
    };
  };
in
{
  #: expose 2222 mesh
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

  services.gitea-actions-runner.instances = {
    nas = {
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
        gzip
        nodejs
        openssh
        wget
        config.nix.package
        inputs.deploy-rs.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];
    };

    ubuntu = {
      enable = true;
      name = "ubuntu-24.04";
      url = "https://${webDomain}";
      tokenFile = config.sops.templates."gitea-runner-env".path;
      labels = [
        "ubuntu-24.04:docker://catthehacker/ubuntu:act-24.04"
      ];
    };
  };

  users.users.gitea-runner = {
    isSystemUser = true;
    group = "gitea-runner";
    home = "/var/lib/gitea-runner";
  };
  users.groups.gitea-runner = { };

  system.activationScripts.gitea-runner-ssh = ''
    mkdir -p /var/lib/gitea-runner/.ssh
    chmod 700 /var/lib/gitea-runner/.ssh
    printf 'Host nas ${sshDomain}\n  IdentityFile /var/lib/gitea-runner/.ssh/id_ed25519\n  StrictHostKeyChecking accept-new\n  Port ${toString sshPort}\n' > /var/lib/gitea-runner/.ssh/config
    chmod 600 /var/lib/gitea-runner/.ssh/config
    chown gitea-runner:gitea-runner /var/lib/gitea-runner/.ssh/config
  '';

  systemd.services.gitea-runner-nas = runnerService;
  systemd.services.gitea-runner-ubuntu = runnerService;

  systemd.services.gitea.unitConfig.RequiresMountsFor = [ "/mnt/data" ];

  systemd.tmpfiles.rules = [
    "d /var/lib/gitea-runner/gcroots 0755 gitea-runner gitea-runner - -"
  ];

  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [
    httpPort
    sshPort
  ];
}
