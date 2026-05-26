{
  # To bootstrap a host:
  #   1. On the host, generate a keypair:
  #        wg genkey | tee /tmp/wg.priv | wg pubkey > /tmp/wg.pub
  #   2. Copy the pubkey into the `publicKey =` line below for this host.
  #   3. On your laptop: `sops secrets/secrets.yaml` and add the new entry
  #      `wg-<hostname>-priv: <contents of /tmp/wg.priv>`
  #   4. Wipe /tmp/wg.priv from the host: `shred -u /tmp/wg.priv`
  #   5. Commit + push. `nh os switch .#<hostname>` to activate.

  hosts = {
    edge = {
      ip = "10.100.0.254";
      publicKey = "";
      listenPort = 51820;
      # Reachable from outside via port-forward on the home router.
      endpoint = "home.kucendro.dev:51820";
    };

    workstation = {
      ip = "10.100.0.1";
      publicKey = "";
      listenPort = 51820;
      # LAN address for edge↔workstation direct path (avoids hairpin).
      # Fill in the workstation's static LAN IP once known.
      lanEndpoint = null;
    };

    nixbook = {
      ip = "10.100.0.2";
      publicKey = "";
      # No endpoint: roaming client, always initiates outward.
    };
  };
}
