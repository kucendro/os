{ pkgs, me, ... }:

{
  imports = [
    ../secrets/sops.nix
    ../development/zsh.nix
    ../display/stylix.nix
    ../home/user.nix
    ../services/services.nix
  ];

  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        consoleMode = "auto";
      };
      timeout = 0;
      efi.canTouchEfiVariables = true;
    };
    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = [
      "quiet"
      "loglevel=3"
    ];
    initrd = {
      verbose = false;
      systemd.enable = true;
      compressor = "zstd";
      compressorArgs = [
        "-19"
        "-T0"
      ];
    };
  };

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
  };

  systemd.services = {
    NetworkManager-wait-online.enable = false;
    systemd-networkd-wait-online.enable = false;
  };

  hardware.enableRedistributableFirmware = true;

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

  time.timeZone = me.timeZone;

  i18n = {
    defaultLocale = me.locale.default;
    extraLocaleSettings = {
      LC_ADDRESS = me.locale.formats;
      LC_IDENTIFICATION = me.locale.formats;
      LC_MEASUREMENT = me.locale.formats;
      LC_MONETARY = me.locale.formats;
      LC_NAME = me.locale.formats;
      LC_NUMERIC = me.locale.formats;
      LC_PAPER = me.locale.formats;
      LC_TELEPHONE = me.locale.formats;
      LC_TIME = me.locale.formats;
    };
  };

  services.gnome.gnome-keyring.enable = true;
  security.pam.services.login.enableGnomeKeyring = true;

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

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
