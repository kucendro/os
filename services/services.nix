{ lib, profile, ... }:

{
  services = {
    resolved.enable = true;
    openssh = {
      enable = true;
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
  }
  // lib.optionalAttrs (profile == "desktop") {
    printing.enable = true;
    udisks2.enable = true;
    gvfs.enable = true;
    clamav = {
      daemon.enable = true;
      updater.enable = true;
    };
    passSecretService.enable = true;
  };

  systemd = lib.mkIf (profile != "desktop") {
    services.fwupd-refresh.enable = false;
    timers.fwupd-refresh.enable = false;
  };
}
