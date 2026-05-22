{
  description = "NixOS configurations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    asus-numberpad-driver = {
      url = "github:asus-linux-drivers/asus-numberpad-driver";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix.url = "github:Mic92/sops-nix";

    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      asus-numberpad-driver,
      sops-nix,
      noctalia,
      home-manager,
      stylix,
      ...
    }@inputs:
    let
      me = import ./me.nix;

      homeManagerConfig = {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.backupFileExtension = "backup";
        home-manager.extraSpecialArgs = { inherit inputs me; };
        home-manager.users.${me.name} = import ./home/home.nix;
      };

      mkSystem =
        {
          targetModule,
          hardwareModule,
          extraModules ? [ ],
        }:
        nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs me; };
          modules = [
            targetModule
            hardwareModule
            sops-nix.nixosModules.sops
            home-manager.nixosModules.home-manager
            stylix.nixosModules.stylix
            homeManagerConfig
          ]
          ++ extraModules;
        };
    in
    {
      nixosConfigurations = {

        nixbook = mkSystem {
          targetModule = ./targets/zenbook.nix;
          hardwareModule = ./targets/zenbook-hw-configuration.nix;
          extraModules = [
            asus-numberpad-driver.nixosModules.default
          ];
        };

        # workstation = mkSystem {
        #   targetModule = ./targets/workstation.nix;
        #   hardwareModule = ./targets/workstation-hw-configuration.nix;
        #   extraModules = [ ];
        # };

      };

    };
}
