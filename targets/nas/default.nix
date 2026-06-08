{ ... }:

{
  imports = [
    ../linux.nix
    ./disko.nix
  ];

  # linux.nix already brings the mesh client (services/mesh/tailscale.nix),
  # the beszel agent, sops, openssh and the user — so the NAS joins the
  # headscale mesh running on edge as soon as it boots with a valid authkey.

  nixpkgs.hostPlatform = "x86_64-linux";
}
