{ ... }:

{
  services = {
    sunshine = {
      enable = true;
      autoStart = false;
      capSysAdmin = true;
      openFirewall = true;
    };
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
    printing.enable = true;
    udisks2.enable = true;
    gvfs.enable = true;
    clamav = {
      daemon.enable = true;
      updater.enable = true;
    };
    gnome.gnome-keyring.enable = true;
    passSecretService.enable = true;
    fwupd.enable = true;
    fstrim.enable = true;
  };
}
