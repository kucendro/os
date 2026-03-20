{ pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    wget
    fastfetch
    btop
    sops
    age
    nixfmt
    adwaita-icon-theme
    nautilus
    gnome-keyring
    rustup
    oxker
    nodejs
    pnpm
    loupe
    grim
    slurp
    gccgo15
    python315
    qdirstat
    fzf
    gpu-screen-recorder
    inetutils
    putty
    wireguard-tools
    brightnessctl
    hypridle
    hyprlock
    ripgrep
    vulnix
  ];
}
