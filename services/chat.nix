{ ... }:

{
  services.matrix-synapse = {
    enable = true;
    dataDir = "/mnt/data/matrix";
  };

  systemd.services.matrix-synapse.unitConfig.RequiresMountsFor = [ "/mnt/data" ];
  mesh.ports.matrix-synapse = 8008;
}
