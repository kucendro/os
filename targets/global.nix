{ pkgs, ... }:

{
  imports = [
    ../secrets/sops.nix
    ../development/zsh.nix
    ../display/stylix.nix
    ../home/kucendro.nix
    ../services/services.nix
  ];

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelPackages = pkgs.linuxPackages_latest; # for the virtual box revert to 6_18
  };

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];

    substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
    ];

    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Prague";

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "cs_CZ.UTF-8";
      LC_IDENTIFICATION = "cs_CZ.UTF-8";
      LC_MEASUREMENT = "cs_CZ.UTF-8";
      LC_MONETARY = "cs_CZ.UTF-8";
      LC_NAME = "cs_CZ.UTF-8";
      LC_NUMERIC = "cs_CZ.UTF-8";
      LC_PAPER = "cs_CZ.UTF-8";
      LC_TELEPHONE = "cs_CZ.UTF-8";
      LC_TIME = "cs_CZ.UTF-8";
    };
  };

  services.gnome.gnome-keyring.enable = true;
  security.pam.services.login.enableGnomeKeyring = true;

  virtualisation.docker.enable = true;

  nixpkgs.config.allowUnfree = true;

  programs.nh = {
    enable = true;
    flake = "~/nixos";
  };

  environment.systemPackages = with pkgs; [
    wget
    fastfetch
    btop
    sops
    age
    nixfmt
    adwaita-icon-theme
    gnome-keyring
    stdenv.cc.cc
    zlib
    libGL
    glibc
    glibc.dev
    gcc
    clang
    gnumake
    autoconf
    automake
    libtool
    pkg-config
    dbus
    oxker
    nodejs
    pnpm
    grim
    slurp
    gccgo15
    python315
    fzf
    inetutils
    putty
    wireguard-tools
    ripgrep
    vulnix
    hypridle
    clamav
    cargo
    rustc
    rust-analyzer
    clippy
    rustfmt
    dbus
    pkg-config
    openssl
  ];

  system.stateVersion = "25.11";
}
