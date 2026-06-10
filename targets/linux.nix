{
  pkgs,
  lib,
  me,
  profile,
  ...
}:

{
  imports = [
    ./common.nix
    ../secrets/sops.nix
    ../development/zsh.nix
    ../home/user.nix
    ../services/services.nix
    ../services/mesh/tailscale.nix
    ../services/monitoring/agent.nix
  ]
  ++ lib.optionals (profile == "desktop") [
    ../display/stylix.nix
    ../display/plymouth.nix
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

  security.sudo.wheelNeedsPassword = profile == "desktop";

  networking.networkmanager.enable = true;

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

  programs.nh = {
    enable = true;
    flake = "~/nixos";
  };

  virtualisation.docker.enable = true;

  environment.systemPackages = (
    with pkgs;
    [
      stdenv.cc.cc
      zlib
      libGL
      glibc
      glibc.dev
      clang
      autoconf
      automake
      libtool
      pkg-config
      dbus
      oxker
      gccgo15
      python315
      inetutils
      putty
      vulnix
      openssl
    ]
  );

  system.stateVersion = "25.11";
}
