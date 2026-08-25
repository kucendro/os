{ pkgs, ... }:

{
  imports = [
    ./opencode.nix
  ];

  home.packages = with pkgs; [
    magic-wormhole
    tokei
    cloudflared
    kubectl
    supabase-cli
    d2
    nmap
    browsh
    libqalculate
    iperf3
    awscli2
    binwalk
    putty
    oxker
    vulnix
    deploy-rs
    nixos-anywhere
  ];
}
