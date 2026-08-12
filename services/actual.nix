{ ... }:

let
  port = 5006;
in
{
  services.actual = {
    enable = true;
    settings = {
      inherit port;
      dataDir = "/mnt/data/actual";
    };
  };

  systemd.services.actual.unitConfig.RequiresMountsFor = [ "/mnt/data" ];
  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ port ];
}
