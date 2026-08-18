{ pkgs, me, ... }:

{
  environment.localBinInPath = true;

  environment.systemPackages = (
    with pkgs;
    [
      nodejs
      pnpm
      cargo
      rustc
      rust-analyzer
      clippy
      rustfmt
      gcc
      gccgo15
      clang
      gnumake
      python315
      autoconf
      automake
      libtool
      pkg-config
      stdenv.cc.cc
      zlib
      libGL
      glibc
      glibc.dev
      openssl
      dbus
      nixfmt
      deploy-rs
      nixos-anywhere
      oxker
      vulnix
      putty
      inetutils
      binwalk
      awscli2
    ]
  );

  home-manager.users.${me.name}.programs = {
    uv = {
      enable = true;
      tool.packages = [
        "graphifyy"
      ];
      tool.prune = true;
    };
  };
}
