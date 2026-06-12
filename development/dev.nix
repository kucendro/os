{ pkgs, ... }:

{
  environment.systemPackages = (
    with pkgs;
    [
      # lang toolchains
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
      # build
      autoconf
      automake
      libtool
      pkg-config
      # native build deps
      stdenv.cc.cc
      zlib
      libGL
      glibc
      glibc.dev
      openssl
      dbus
      # nix
      nixfmt
      deploy-rs
      nixos-anywhere
      # misc dev
      oxker
      vulnix
      putty
      inetutils
    ]
  );
}
