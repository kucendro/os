{
  pkgs,
  me,
  ...
}:

{
  imports = [
    ./common.nix
    ../secrets/sops.nix
    ../services/tailscale.nix
  ];

  nixpkgs.hostPlatform = "aarch64-darwin";
  system.primaryUser = me.name;
  nix.enable = true;

  programs.zsh.enable = true;

  services.tailscale.enable = true;

  system.activationScripts.tailscaleUp.text = ''
    if ! /usr/bin/sudo -u ${me.name} /run/current-system/sw/bin/tailscale status >/dev/null 2>&1; then
      /run/current-system/sw/bin/tailscale up \
        --login-server=https://edge.kucendro.dev \
        --auth-key="$(cat /Users/${me.name}/.docker-secrets/tailscale-authkey)" \
        || true
    fi
  '';

  system.stateVersion = 6;

  sops.age.keyFile = "/Users/${me.name}/.config/sops/age/keys.txt";
  sops.age.sshKeyPaths = [ ];
  sops.gnupg.sshKeyPaths = [ ];

  environment.variables.NH_FLAKE = "/Users/${me.name}/nixos";
  environment.systemPackages = [ pkgs.nh ];
}
