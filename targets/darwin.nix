{
  pkgs,
  me,
  ...
}:

{
  imports = [
    ./common.nix
    ../secrets/sops.nix
    ../services/monitoring/agent-darwin.nix
  ];

  nixpkgs.hostPlatform = "aarch64-darwin";
  system.primaryUser = me.name;
  nix.enable = true;

  programs.zsh.enable = true;

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = false;
      cleanup = "uninstall";
      extraFlags = [ "--force" ];
    };

    casks = [ "tailscale-app" ];
    taps = [ "LizardByte/homebrew" ];
    brews = [ "lizardbyte/homebrew/sunshine-beta" ];
  };

  system.stateVersion = 6;

  sops.age.keyFile = "/Users/${me.name}/.config/sops/age/keys.txt";
  sops.age.sshKeyPaths = [ ];
  sops.gnupg.sshKeyPaths = [ ];

  environment.variables.NH_FLAKE = "/Users/${me.name}/nixos";
  environment.systemPath = [ "/opt/homebrew/bin" ];
  environment.systemPackages = [ pkgs.nh ];
}
