{ pkgs, me, ... }:

{
  environment.localBinInPath = true;

  environment.systemPackages = import ../development/dev-packages.nix pkgs;

  home-manager.users.${me.name}.programs = {
    uv = {
      enable = true;
      tool.packages = [
        "graphifyy"
      ];
      tool.prune = true;
    };
  };
}
