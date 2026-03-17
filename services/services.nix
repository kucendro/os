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
    cloudflare-warp.enable = true;
  };
}
