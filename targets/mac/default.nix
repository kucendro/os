{
  pkgs,
  me,
  ...
}:

# Bootstrap on a fresh Mac:
#   1. Install Nix (Determinate Systems installer recommended).
#   2. Generate an age key for sops:
#        mkdir -p ~/.config/sops/age
#        nix run nixpkgs#age -- -k -o ~/.config/sops/age/keys.txt
#      Copy the resulting public key into ../../.sops.yaml as &mac and
#      run `sops updatekeys ../../secrets/secrets.yaml` from a host that
#      can already decrypt.
#   3. Populate the nixbook-pubkey and wg-workstation-priv values:
#        sops ../../secrets/secrets.yaml
#   4. First activation:
#        sudo nix run nix-darwin -- switch --flake .#mac

{
  imports = [
    ../darwin.nix
  ];

  users.users.${me.name} = {
    home = "/Users/${me.name}";
    shell = pkgs.zsh;
  };
}
