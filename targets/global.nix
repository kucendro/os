{
  pkgs,
  lib,
  me,
  profile,
  ...
}:

{
  imports = [
    ../secrets/sops.nix
    ../development/zsh.nix
    ../home/user.nix
    ../services/services.nix
  ]
  ++ lib.optionals (profile == "desktop") [
    ../display/stylix.nix
  ];

  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        consoleMode = "auto";
      };
      timeout = 3;
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

  services.gnome.gnome-keyring.enable = lib.mkIf (profile == "desktop") true;
  security.pam.services.login.enableGnomeKeyring = lib.mkIf (profile == "desktop") true;

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = false;
  };

  environment.sessionVariables = {
    SSH_AUTH_SOCK = lib.mkIf (profile == "desktop") "$XDG_RUNTIME_DIR/gcr/ssh";
    NIXOS_OZONE_WL = lib.mkIf (profile == "desktop") "1";
    GDK_BACKEND = lib.mkIf (profile == "desktop") "wayland";
    XDG_SESSION_TYPE = lib.mkIf (profile == "desktop") "wayland";
    QT_QPA_PLATFORM = lib.mkIf (profile == "desktop") "wayland";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = lib.mkIf (profile == "desktop") "1";
    XDG_CURRENT_DESKTOP = lib.mkIf (profile == "desktop") "Hyprland";
    XDG_SESSION_DESKTOP = lib.mkIf (profile == "desktop") "Hyprland";
  };

  virtualisation.docker.enable = true;

  nixpkgs.config.allowUnfree = true;

  programs.nh = {
    enable = true;
    flake = "~/nixos";
  };

  environment.systemPackages = (
    with pkgs;
    [
      wget
      fastfetch
      btop
      sops
      age
      nixfmt
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
      gccgo15
      python315
      fzf
      inetutils
      putty
      wireguard-tools
      ripgrep
      vulnix
      cargo
      rustc
      rust-analyzer
      clippy
      rustfmt
      openssl
    ]
  );

  system.stateVersion = "25.11";
}
