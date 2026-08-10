{
  description = "Kucendro's nix configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    sops-nix.url = "github:Mic92/sops-nix";

    noctalia = {
      url = "github:noctalia-dev/noctalia/cachix/";
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

    irlume = {
      url = "github:archledger/irlume";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    colibri = {
      url = "github:JustVugg/colibri";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    secrets = {
      url = "git+ssh://git@nas.ts.kucendro.dev:2222/kucendro/secrets.git";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      sops-nix,
      noctalia,
      home-manager,
      stylix,
      disko,
      nix-darwin,
      nixos-generators,
      deploy-rs,
      irlume,
      colibri,
      secrets,
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
          specialArgs = {
            inherit inputs me profile;
            secretsDir = inputs.secrets;
          };
          modules = [
            { networking.hostName = hostName; }
            targetModule
            hardwareModule
            sops-nix.nixosModules.sops
            home-manager.nixosModules.home-manager
            (homeManagerConfig profile)
            (
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
            )
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
          specialArgs = {
            inherit inputs me profile;
            secretsDir = inputs.secrets;
          };
          modules = [
            { networking.hostName = hostName; }
            targetModule
            sops-nix.darwinModules.sops
            home-manager.darwinModules.home-manager
            (homeManagerConfig profile)
            (
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
            )
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
            irlume.nixosModules.irlume
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
          remoteBuild = true;
          profiles.system = {
            user = "root";
            path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.edge;
          };
        };

        nixbook = {
          hostname = "nixbook";
          sshUser = me.name;
          remoteBuild = true;
          profiles.system = {
            user = "root";
            path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.nixbook;
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

      packages = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-darwin" ] (
        system:
        nixpkgs.lib.mapAttrs' (n: v: nixpkgs.lib.nameValuePair "termux-setup-${n}" v) (
          import ./services/termux-setup.nix {
            lib = nixpkgs.lib;
            inherit me;
          }
            nixpkgs.legacyPackages.${system}
        )
      );

      checks = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-darwin" ] (
        system: deploy-rs.lib.${system}.deployChecks self.deploy
      );

      apps = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-darwin" ] (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          diagram = {
            type = "app";
            meta.description = "Regenerate topology, diagrams and wiki";
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
              python3 "$scripts/gen-wiki.py" "$@"
            ''}";
          };

          termux-artifacts = {
            type = "app";
            meta.description = "Render termux bootstrap scripts + QRs into docs/termux";
            program =
              let
                setups = import ./services/termux-setup.nix {
                  lib = nixpkgs.lib;
                  inherit me;
                } pkgs;
                render = nixpkgs.lib.mapAttrsToList (phone: drv: ''
                  ${drv}/bin/termux-setup-${phone} > "$out/${phone}.sh"
                  ${drv}/bin/termux-setup-${phone} --png "$out/${phone}.png"
                '') setups;
              in
              "${pkgs.writeShellScript "gen-termux-artifacts" ''
                set -euo pipefail
                out="''${1:-docs/termux}"
                mkdir -p "$out"
                ${builtins.concatStringsSep "\n" render}
              ''}";
          };
        }
      );

    };
}
