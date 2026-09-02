{
  description = "Kucendro's nix configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    sops-nix.url = "github:Mic92/sops-nix";

    noctalia = {
      url = "github:noctalia-dev/noctalia/cachix/";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ai-usagebar = {
      url = "github:akitaonrails/ai-usagebar";
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
      url = "git+ssh://git@nas:2222/kucendro/secrets.git";
      flake = false;
    };

    nixdiag = {
      url = "github:kucendro/nixdiag";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lazybaka = {
      url = "git+ssh://git@nas:2222/kucendro/lazybaka.git";
      inputs.nixpkgs.follows = "nixpkgs";
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
      nixdiag,
      ...
    }@inputs:
    let
      me = import (inputs.secrets + "/me.nix");

      flakeDir = "os";

      systems = [
        "x86_64-linux"
        "aarch64-darwin"
      ];

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

      inherit
        (import ./lib/mk-system.nix {
          inherit
            inputs
            me
            flakeDir
            hostNames
            ;
        })
        mkSystem
        mkDarwin
        ;

    in

    {
      nixosConfigurations = nixpkgs.lib.mapAttrs mkSystem nixosHosts;

      darwinConfigurations = nixpkgs.lib.mapAttrs mkDarwin darwinHosts;

      deploy = import ./flake/deploy.nix {
        inherit deploy-rs me self;
      };

      nixdiag = {
        out = "docs";
        title = "kucendro infrastructure wiki";
        extraLinks.Termux = "termux.md";
        domains = me.domains;
        theme = "light";
      };

      packages = nixpkgs.lib.genAttrs systems (
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
          docs = import ./flake/docs.nix {
            inherit
              nixdiag
              nixpkgs
              self
              me
              hostNames
              ;
          } system;
        }
      );

      checks = nixpkgs.lib.genAttrs systems (
        system:
        {
          inherit (deploy-rs.lib.${system}.deployChecks self.deploy) deploy-schema;
        }
        // nixpkgs.lib.optionalAttrs (system == "x86_64-linux") {
          docs = self.packages.${system}.docs;
        }
      );

      apps = nixpkgs.lib.genAttrs systems (
        import ./flake/apps.nix {
          inherit nixpkgs;
        }
      );

    };
}
