{ pkgs, ... }:

{
  imports = [
    ./opencode.nix
  ];

  home.packages = with pkgs; [
    magic-wormhole
    just
    tokei
    lefthook
    cloudflared
    # ollama
    kubectl
    sqlx-cli
    supabase-cli
    d2
    nmap
    # maven
    # javaPackages.compiler.openjdk25
    # php
    browsh
    libqalculate
    iperf3
  ];
}
