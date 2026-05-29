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

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-generators = {
      url = "github:nix-community/nixos-generators";
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
      disko,
      nix-darwin,
      nixos-generators,
      ...
    }@inputs:
    let
      me = import ./me.nix;

      homeManagerConfig = profile: {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.backupFileExtension = "backup";
        home-manager.extraSpecialArgs = { inherit inputs me profile; };
        home-manager.users.${me.name} = import ./home/home.nix;
      };

      mkSystem =
        hostName:
        {
          targetModule,
          hardwareModule,
          profile,
          extraModules ? [ ],
        }:
        nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs me profile; };
          modules = [
            { networking.hostName = hostName; }
            targetModule
            hardwareModule
            sops-nix.nixosModules.sops
            home-manager.nixosModules.home-manager
            (homeManagerConfig profile)
          ]
          ++ nixpkgs.lib.optionals (profile == "desktop") [
            stylix.nixosModules.stylix
          ]
          ++ extraModules;
        };

      mkDarwin =
        hostName:
        {
          targetModule,
          profile,
          extraModules ? [ ],
        }:
        nix-darwin.lib.darwinSystem {
          specialArgs = { inherit inputs me profile; };
          modules = [
            { networking.hostName = hostName; }
            targetModule
            sops-nix.darwinModules.sops
            home-manager.darwinModules.home-manager
            (homeManagerConfig profile)
          ]
          ++ extraModules;
        };

      mkWorkstationDocker =
        system:
        nixos-generators.nixosGenerate {
          inherit system;
          format = "docker";
          specialArgs = {
            inherit inputs me;
            profile = "headless";
          };
          modules = [
            { networking.hostName = "workstation"; }
            ./targets/workstation
            home-manager.nixosModules.home-manager
            (homeManagerConfig "headless")
          ];
        };
    in
    {
      nixosConfigurations = nixpkgs.lib.mapAttrs mkSystem {

        nixbook = {
          profile = "desktop";
          targetModule = ./targets/nixbook;
          hardwareModule = ./targets/nixbook/hw-configuration.nix;
          extraModules = [
            asus-numberpad-driver.nixosModules.default
          ];
        };

        edge = {
          profile = "headless";
          targetModule = ./targets/edge;
          hardwareModule = ./targets/edge/hw-configuration.nix;
          extraModules = [
            disko.nixosModules.disko
          ];
        };

      };

      darwinConfigurations = nixpkgs.lib.mapAttrs mkDarwin {

        mac = {
          profile = "darwin";
          targetModule = ./targets/mac;
        };

      };

      packages = {
        aarch64-linux.workstation-docker = mkWorkstationDocker "aarch64-linux";
        x86_64-linux.workstation-docker = mkWorkstationDocker "x86_64-linux";
      };

    };
}
