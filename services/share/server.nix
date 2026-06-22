{ pkgs, ... }:

{
  services.samba = {
    enable = true;
    openFirewall = false;
    nmbd.enable = false;
    winbindd.enable = false;
    settings = {
      global = {
        "hosts allow" = "100.64.0.0/10 127.0.0.1";
      };
      data = {
        path = "/mnt/data/share";
        "read only" = "no";
        "valid users" = "kucendro";
        "force user" = "kucendro";
      };
    };
  };

  systemd.services.samba-smbd.unitConfig.RequiresMountsFor = [ "/mnt/data" ];

  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [
    139
    445
  ];
}
