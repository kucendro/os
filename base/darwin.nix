{
  pkgs,
  me,
  flakeDir,
  ...
}:

{
  imports = [
    ./common.nix
    ../services/monitoring/agent-darwin.nix
  ];

  nixpkgs.hostPlatform = "aarch64-darwin";
  system.primaryUser = me.name;

  users.users.${me.name} = {
    home = "/Users/${me.name}";
    shell = pkgs.zsh;
  };

  nix = {
    enable = true;
    optimise.automatic = true;
  };

  programs.zsh.enable = true;

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = false;
  };

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = false;
      cleanup = "uninstall";
      extraFlags = [ "--force" ];
    };

    casks = [ "tailscale-app" ];
  };

  system.stateVersion = 6;

  sops.age.keyFile = "/Users/${me.name}/.config/sops/age/keys.txt";
  sops.age.sshKeyPaths = [ ];
  sops.gnupg.sshKeyPaths = [ ];

  environment.variables.NH_FLAKE = "/Users/${me.name}/${flakeDir}";
  environment.systemPath = [ "/opt/homebrew/bin" ];
  environment.systemPackages = [ pkgs.nh ];
}
