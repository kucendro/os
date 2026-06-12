{ pkgs, ... }:

{
  imports = [
    ./opencode.nix
  ];

  home.packages = with pkgs; [
    nushell
    magic-wormhole
    just
    tokei
    taskwarrior3
    lefthook
    cloudflared
    github-copilot-cli
    ollama
    kubectl
    sqlx-cli
    supabase-cli
    d2
    nmap
    maven
    javaPackages.compiler.openjdk25
    php
    browsh
    libqalculate
  ];
}
