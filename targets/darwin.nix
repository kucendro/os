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

  sops.age.keyFile = "/Users/${me.name}/.config/sops/age/keys.txt";
  sops.age.sshKeyPaths = [ ];
  sops.gnupg.sshKeyPaths = [ ];

  environment.variables.NH_FLAKE = "/Users/${me.name}/nixos";
  environment.systemPackages = [ pkgs.nh ];
}
