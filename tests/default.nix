{
  nixpkgs,
  nixosHosts,
  linuxModules,
  specialArgs,
}:

system:

let
  pkgs = nixpkgs.legacyPackages.${system};
  lib = nixpkgs.lib;

  overrides = {
    edge = {
      virtualisation.memorySize = 2048;
      vm.skip = [ "metric-badges" ];
    };
    nas.vm.skip = [
      "kucendro-github"
      "qore"
      "gitea-runner-nas"
      "gitea-runner-ubuntu"
    ];
    stockholm.vm.skip = [
      "amazon-ssm-agent"
      "growpart"
      "home-manager-kucendro"
    ];
  };

  test =
    name: host:
    pkgs.testers.runNixOSTest {
      name = "vm-${name}";
      node.specialArgs = specialArgs host.profile;
      node.pkgsReadOnly = false;
      nodes.${name}.imports = linuxModules name (host // { hardwareModule = { }; }) ++ [
        ./vm.nix
        (overrides.${name} or { })
      ];
      testScript =
        { nodes, ... }:
        ''
          skip: list[str] = ${builtins.toJSON nodes.${name}.vm.skip}
          ports: dict[str, list[str]] = ${builtins.toJSON nodes.${name}.vm.ports}
        ''
        + builtins.readFile ./boot.py;
    };
in
lib.mapAttrs' (name: host: lib.nameValuePair "vm-${name}" (test name host)) nixosHosts
