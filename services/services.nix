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
    openssh.enable = true;
    printing.enable = true;
    udisks2.enable = true;
    gvfs.enable = true;
    clamav = {
      daemon.enable = true;
      updater.enable = true;
    };
    gnome.gnome-keyring.enable = true;
    passSecretService.enable = true;
  };
}
