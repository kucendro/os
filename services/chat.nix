{ ... }:

{
  services.matrix-synapse = {
    enable = true;
    dataDir = "/mnt/data/matrix";
  };

  systemd.services.matrix-synapse.unitConfig.RequiresMountsFor = [ "/mnt/data" ];
  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ 8008 ];
}
