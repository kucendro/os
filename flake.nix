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
      me = import (inputs.secrets + "/me.nix");

      flakeDir = "brain";

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
        home-manager.users.${me.name} = import ./home/home.nix;
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
          specialArgs = {
            inherit
              inputs
              me
              profile
              hostNames
              flakeDir
              ;
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
            inherit
              inputs
              me
              profile
              hostNames
              flakeDir
              ;
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

      nixosHosts = {

        nixbook = {
          profile = "desktop";
          targetModule = ./hosts/nixbook;
          hardwareModule = ./hosts/nixbook/hw-configuration.nix;
          extraModules = [
            irlume.nixosModules.irlume
          ];
        };

        edge = {
          profile = "headless";
          targetModule = ./hosts/edge;
          hardwareModule = ./hosts/edge/hw-configuration.nix;
          extraModules = [
            disko.nixosModules.disko
          ];
        };

        nas = {
          profile = "headless";
          targetModule = ./hosts/nas;
          hardwareModule = ./hosts/nas/hw-configuration.nix;
          extraModules = [
            disko.nixosModules.disko
          ];
        };

        stockholm = {
          profile = "workstation";
          targetModule = ./hosts/aws/stockholm.nix;
        };

      };

      darwinHosts = {

        mac = {
          profile = "darwin";
          targetModule = ./hosts/mac;
        };

      };

      hostNames = builtins.attrNames nixosHosts ++ builtins.attrNames darwinHosts;

    in

    {
      nixosConfigurations = nixpkgs.lib.mapAttrs mkSystem nixosHosts;

      darwinConfigurations = nixpkgs.lib.mapAttrs mkDarwin darwinHosts;

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
          remoteBuild = true;
          profiles.system = {
            user = "root";
            path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.nas;
          };
        };

        stockholm = {
          hostname = "stockholm.ts.kucendro.dev";
          sshUser = me.name;
          remoteBuild = true;
          profiles.system = {
            user = "root";
            path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.stockholm;
          };
        };
      };

      packages = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-darwin" ] (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          termux = nixpkgs.lib.mapAttrs' (n: v: nixpkgs.lib.nameValuePair "termux-setup-${n}" v) (
            import ./services/termux-setup.nix {
              lib = nixpkgs.lib;
              inherit me;
              hosts = hostNames;
            } pkgs
          );
        in
        termux
        // nixpkgs.lib.optionalAttrs (system == "x86_64-linux") {
          workstation = import ./packages/workstation.nix {
            pkgs = import nixpkgs {
              inherit system;
              config.allowUnfree = true;
            };
            inherit me;
            lib = nixpkgs.lib;
          };
        }
      );

      checks = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-darwin" ] (
        system: deploy-rs.lib.${system}.deployChecks self.deploy
      );

      apps = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-darwin" ] (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        nixpkgs.lib.optionalAttrs (system == "x86_64-linux") {
          runpod = {
            type = "app";
            meta.description = "Push the workstation image to GHCR and manage the RunPod pod";
            program = nixpkgs.lib.getExe (pkgs.writeShellApplication {
              name = "runpod";
              runtimeInputs = [
                pkgs.skopeo
                pkgs.runpodctl
                pkgs.gzip
                pkgs.coreutils
              ];
              text = builtins.readFile ./automations/runpod.sh;
            });
          };
        }
        // {
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
              scripts=${./automations}
              python3 "$scripts/gen-topology.py" "$@"
              python3 "$scripts/gen-diagram.py" "$@"
              python3 "$scripts/gen-wiki.py" "$@"
            ''}";
          };

          termux-artifacts = {
            type = "app";
            meta.description = "Render termux bootstrap scripts";
            program =
              let
                setups = import ./services/termux-setup.nix {
                  lib = nixpkgs.lib;
                  inherit me;
                  hosts = hostNames;
                } pkgs;
                render = nixpkgs.lib.mapAttrsToList (phone: drv: ''
                  ${drv}/bin/termux-setup-${phone} > "$out/${phone}.sh"
                  ${drv}/bin/termux-setup-${phone} --png "$out/${phone}.png"
                  cp "$out/${phone}.png" "$wiki/${phone}.png"
                  printf '## %s\n\n![%s](termux/%s.png)\n\n' '${phone}' '${phone}' '${phone}' >> "$page"
                '') setups;
              in
              "${pkgs.writeShellScript "gen-termux-artifacts" ''
                set -euo pipefail
                out="''${1:-docs/termux}"
                wiki="docs/wiki/src/termux"
                page="docs/wiki/src/termux.md"
                mkdir -p "$out" "$wiki"
                printf '# Termux bootstrap\n\nScan into Termux; scripts live in docs/termux.\n\n' > "$page"
                ${builtins.concatStringsSep "\n" render}
              ''}";
          };
        }
      );

    };
}
