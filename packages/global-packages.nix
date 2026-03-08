{ config, pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    wget
    wine64
    fastfetch
    btop
    sops
    age
    nixfmt
    kitty
    adwaita-icon-theme
    nautilus
    gnome-keyring
    rustup
    oxker
    nodejs
    pnpm
    loupe
    wineWowPackages.stable
    grim
    slurp
    gccgo15
    python315
    qdirstat
    fzf
    gpu-screen-recorder

    # ? Power & idle management
    brightnessctl
    hypridle
    hyprlock
  ];
}
