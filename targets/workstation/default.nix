{
  pkgs,
  lib,
  me,
  ...
}:

let
  registry = (import ../../services/connection/peers.nix).hosts;
  selfName = "workstation";
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
  imports = [
    ../common.nix
    ../../development/zsh.nix
  ];

  boot.isContainer = true;

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PubkeyAuthentication = true;
      PermitRootLogin = "no";
    };
  };

  users.users.${me.name} = {
    isNormalUser = true;
    description = me.fullName;
    hashedPassword = null;
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      # Add nixbook's user pubkey here once available.
    ];
  };

  # wg key arrives via docker bind-mount from the host's sops-managed file.
  networking.wireguard.interfaces.wg0 = {
    ips = [ "${self.ip}/24" ];
    listenPort = self.listenPort or null;
    privateKeyFile = "/etc/wireguard/wg.priv";
    peers = lib.mapAttrsToList mkPeer others;
  };

  networking.useDHCP = false;
  networking.firewall.enable = false;

  system.stateVersion = "25.11";
}
