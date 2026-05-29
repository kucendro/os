{
  pkgs,
  me,
  ...
}:

{
  imports = [
    ./common.nix
    ../secrets/sops.nix
  ];

  nixpkgs.hostPlatform = "aarch64-darwin";

  system.primaryUser = me.name;

  nix.enable = true;

  programs.zsh.enable = true;

  system.stateVersion = 6;

  environment.systemPackages = with pkgs; [
    # Darwin-only extras go here.
  ];
}
