{
  pkgs,
  lib,
  me,
  flakeDir,
  ...
}:

{
  imports = [
    ./common.nix
    ../development/zsh.nix
    ../home/user.nix
    ../services/services.nix
    ../services/mesh/tailscale.nix
    ../services/monitoring/agent.nix
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

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  systemd.services = {
    NetworkManager-wait-online.enable = false;
    systemd-networkd-wait-online.enable = false;
  };

  hardware.enableRedistributableFirmware = true;

  security.sudo.wheelNeedsPassword = lib.mkDefault false;

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

  programs.mosh.enable = true;

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = false;
  };

  programs.nix-ld.enable = true;

  programs.nh = {
    enable = true;
    flake = "/home/${me.name}/${flakeDir}";
  };

  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    autoPrune.enable = true;
    extraPackages = [ pkgs.docker-buildx ];
    daemon.settings = {
      features.cdi = true;
      max-concurrent-downloads = 10;
      max-concurrent-uploads = 10;
      builder.gc = {
        enabled = true;
        defaultKeepStorage = "40GB";
      };
    };
  };

  system.stateVersion = "25.11";
}
