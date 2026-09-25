{ ... }:

{
  imports = [
    ../../base/linux.nix
    ./disko.nix
    ../../services/mesh/nginx.nix
    ../../services/mesh/headscale.nix
    ../../services/mesh/public.nix
    ../../services/mesh/proxied/services.nix
    ../../services/mesh/wiki.nix
    ../../services/mesh/dev.nix
    ../../services/monitoring/hub.nix
    ../../services/monitoring/speed.nix
    ../../services/monitoring/3rd/badges
  ];

  nixpkgs.hostPlatform = "x86_64-linux";
}
