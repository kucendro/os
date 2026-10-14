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
    nix-darwin
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

  sopsModule = hostName: inputs.secrets + "/sops/${hostName}.nix";

  nodesModule =
    hostName:
    { config, lib, ... }:
    {
      options.nodes = lib.mkOption {
        type = lib.types.raw;
        readOnly = true;
        internal = true;
        default = lib.mapAttrs (
          name: host: if name == hostName then config else host.config
        ) inputs.self.nixosConfigurations;
      };
    };

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

  linuxModules =
    hostName:
    {
      targetModule,
      hardwareModule ? { },
      profile,
      extraModules ? [ ],
    }:
    [
      { networking.hostName = hostName; }
      (nodesModule hostName)
      targetModule
      hardwareModule
      sops-nix.nixosModules.sops
      home-manager.nixosModules.home-manager
      (homeManagerConfig profile)
      (sopsModule hostName)
      nixdiag.nixosModules.default
    ]
    ++ extraModules;

  mkSystem =
    hostName: host:
    nixpkgs.lib.nixosSystem {
      specialArgs = specialArgs host.profile;
      modules = linuxModules hostName host;
    };

  mkDarwin =
    hostName:
    {
      targetModule,
      profile,
      extraModules ? [ ],
    }:
    nix-darwin.lib.darwinSystem {
      specialArgs = specialArgs profile;
      modules = [
        { networking.hostName = hostName; }
        (nodesModule hostName)
        targetModule
        sops-nix.darwinModules.sops
        home-manager.darwinModules.home-manager
        (homeManagerConfig profile)
        (sopsModule hostName)
      ]
      ++ extraModules;
    };
in
{
  inherit
    mkSystem
    mkDarwin
    linuxModules
    specialArgs
    ;
}
