{
  inputs,
  me,
  flakeDir,
  hostNames,
}:

let
  inherit (inputs)
    nixpkgs
    sops-nix
    home-manager
    nixdiag
    ;

  homeManagerConfig = profile: {
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.backupFileExtension = "backup";
    home-manager.extraSpecialArgs = {
      inherit
        inputs
        me
        profile
        flakeDir
        ;
    };
    home-manager.users.${me.name} = import ../home/home.nix;
  };

  sopsModule = (
    {
      secretsDir,
      config,
      lib,
      me,
      ...
    }:
    import (inputs.secrets + "/sops.nix") {
      inherit
        secretsDir
        config
        lib
        me
        ;
    }
  );

  specialArgs = profile: {
    inherit
      inputs
      me
      profile
      hostNames
      flakeDir
      ;
    secretsDir = inputs.secrets;
  };

  mkSystem =
    hostName:
    {
      targetModule,
      hardwareModule ? { },
      profile,
      extraModules ? [ ],
    }:
    nixpkgs.lib.nixosSystem {
      specialArgs = specialArgs profile;
      modules = [
        { networking.hostName = hostName; }
        targetModule
        hardwareModule
        sops-nix.nixosModules.sops
        home-manager.nixosModules.home-manager
        (homeManagerConfig profile)
        sopsModule
        nixdiag.nixosModules.default
      ]
      ++ extraModules;
    };
in
{
  inherit mkSystem;
}
