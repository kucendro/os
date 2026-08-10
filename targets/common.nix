{
  pkgs,
  me,
  lib,
  profile,
  ...
}:

{
  imports = lib.optionals (profile == "desktop" || profile == "workstation") [
    ../development/dev.nix
  ];

  time.timeZone = me.timeZone;

  nixpkgs.config.allowUnfree = true;

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];

    trusted-users = [
      "root"
      me.name
    ];

    substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
      "https://noctalia.cachix.org"
    ];

    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
    ];
  };

  programs = {
    mosh.enable = true;

    gnupg.agent = {
      enable = true;
      enableSSHSupport = false;
    };
  };

  environment.systemPackages = with pkgs; [
    wget
    btop
    sops
    age
    ripgrep
    fzf
    wireguard-tools
    fastfetch
  ];
}
