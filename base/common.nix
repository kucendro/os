{
  pkgs,
  me,
  ...
}:

{
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
      "http://nas.${me.domains.mesh}:5008"
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
      "https://noctalia.cachix.org"
    ];

    trusted-public-keys = [
      "nas-cache-1:wHF3QuEzDNfN9DQ+nxE5mMW1wMd/joIpprSUALJ5ajg="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
    ];

    connect-timeout = 5;
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
    manix
  ];
}
