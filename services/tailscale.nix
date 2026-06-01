{ ... }:

{
  services.tailscale = {
    enable = true;
    # authKeyFile re-enabled once edge.kucendro.dev is reachable + ACME issued.
    # In the meantime, run on each host once: sudo tailscale up --login-server=https://edge.kucendro.dev
    extraUpFlags = [
      "--login-server=https://edge.kucendro.dev"
    ];
  };
}
