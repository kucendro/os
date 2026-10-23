{
  config,
  lib,
  ...
}:

{
  services = {
    resolved.enable = true;
    openssh = {
      enable = true;
      openFirewall = false;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "no";
        KbdInteractiveAuthentication = false;
        PubkeyAuthentication = true;
        AuthenticationMethods = "publickey";
        MaxAuthTries = 3;
        ClientAliveInterval = 300;
        ClientAliveCountMax = 2;
      };
    };
    fwupd.enable = true;
    fstrim.enable = true;
    iperf3.enable = true;
  };

  mesh.ports.iperf3 = config.services.iperf3.port;

  systemd = {
    services.fwupd-refresh.enable = lib.mkDefault false;
    timers.fwupd-refresh.enable = lib.mkDefault false;
  };
}
