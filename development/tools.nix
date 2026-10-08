{ pkgs, ... }:

{
  imports = [
    ./opencode.nix
    ./anthropic.nix
  ];

  home.packages =
    with pkgs;
    [
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
      vulnix
      deploy-rs
      nixos-anywhere
      gh
    ]
    ++ lib.optionals stdenv.hostPlatform.isLinux [ oxker ];
}
