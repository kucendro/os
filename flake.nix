{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    asus-numberpad-driver = {
          url = "github:asus-linux-drivers/asus-numberpad-driver";
          inputs.nixpkgs.follows = "nixpkgs";
        };

  };

  outputs = { self, nixpkgs, asus-numberpad-driver, ... } @ inputs: {
    
    nixosConfigurations.nixbook = nixpkgs.lib.nixosSystem {
            specialArgs = { inherit inputs; };
            modules = [
                ./configuration.nix
                asus-numberpad-driver.nixosModules.default
            ];
        };

    packages.x86_64-linux.hello = nixpkgs.legacyPackages.x86_64-linux.hello;
    packages.x86_64-linux.default = self.packages.x86_64-linux.hello;


  };
}
