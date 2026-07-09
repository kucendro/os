{
  description = "Kucendro's nix configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    # asus-numberpad-driver = {
    #   url = "github:asus-linux-drivers/asus-numberpad-driver";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    sops-nix.url = "github:Mic92/sops-nix";

    noctalia = {
      url = "github:noctalia-dev/noctalia-shell/3abfa1fc09b62dc4cdeeb7b787886f075696f0b7";
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

    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      # asus-numberpad-driver,
      sops-nix,
      noctalia,
      home-manager,
      stylix,
      disko,
      nix-darwin,
      nixos-generators,
      deploy-rs,
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

    in

    {
      nixosConfigurations = nixpkgs.lib.mapAttrs mkSystem {

        nixbook = {
          profile = "desktop";
          targetModule = ./targets/nixbook;
          hardwareModule = ./targets/nixbook/hw-configuration.nix;
          extraModules = [
            # asus-numberpad-driver.nixosModules.default
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

        nas = {
          profile = "headless";
          targetModule = ./targets/nas;
          hardwareModule = ./targets/nas/hw-configuration.nix;
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

      deploy.nodes = {

        edge = {
          hostname = "edge.kucendro.dev";
          sshUser = me.name;
          profiles.system = {
            user = "root";
            path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.edge;
          };
        };

        # mac = {
        #   hostname = "mac";
        #   sshUser = me.name;
        #   remoteBuild = true;
        #   interactiveSudo = true;
        #   magicRollback = false;
        #   profiles.system = {
        #     user = "root";
        #     path = deploy-rs.lib.aarch64-darwin.activate.darwin self.darwinConfigurations.mac;
        #   };
        # };

        nas = {
          hostname = "nas";
          sshUser = me.name;
          profiles.system = {
            user = "root";
            path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.nas;
          };
        };
      };

      checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;

      apps = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-darwin" ] (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          diagram = {
            type = "app";
            program = "${pkgs.writeShellScript "gen-diagram" ''
              export PATH=${
                nixpkgs.lib.makeBinPath [
                  pkgs.python3
                  pkgs.d2
                ]
              }:$PATH
              set -e
              scripts=${./scripts}
              python3 "$scripts/gen-topology.py" "$@"
              python3 "$scripts/gen-diagram.py" "$@"
            ''}";
          };
        }
      );

    };
}
