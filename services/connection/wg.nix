{ config, ... }:

{
  networking.wireguard.interfaces.wg0 = {
    ips = [ "10.100.0.1/24" ];

    listenPort = 51820;

    privateKeyFile = config.sops.secrets.wg-private-key.path;

    peers = [
      {
        publicKey = config.sops.secrets.wg-peer-public-key.path;
        presharedKeyFile = config.sops.secrets.wg-preshared-key.path;
        allowedIPs = [ "10.100.0.2/32" ];
        persistentKeepalive = 25;
      }
    ];
  };

  networking.firewall.allowedUDPPorts = [ 51820 ];
}
