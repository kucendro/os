{ config, lib, ... }:

let
  registry = (import ./peers.nix).hosts;
  selfName = config.networking.hostName;
  self = registry.${selfName};
  others = lib.filterAttrs (n: p: n != selfName && p.publicKey != "") registry;

  mkPeer = _name: peer: {
    publicKey = peer.publicKey;
    allowedIPs = [ "${peer.ip}/32" ];
    endpoint = peer.endpoint or peer.lanEndpoint or null;
    persistentKeepalive = 25;
  };
in

{
  networking.wireguard.interfaces.wg0 = {
    ips = [ "${self.ip}/24" ];
    listenPort = self.listenPort or null;
    privateKeyFile = config.sops.secrets."wg-${selfName}-priv".path;
    peers = lib.mapAttrsToList mkPeer others;
  };

  networking.firewall.allowedUDPPorts = lib.optional (
    self ? listenPort && self.listenPort != null
  ) self.listenPort;
}
