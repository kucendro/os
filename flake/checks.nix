{
  nixpkgs,
  self,
}:

system:

let
  pkgs = nixpkgs.legacyPackages.${system};
  lib = nixpkgs.lib;

  packages = self.packages.${system};
  apps = self.apps.${system};

  setups = lib.filterAttrs (name: _: lib.hasInfix "-setup-" name) packages;

  scripts = lib.filter (lib.hasSuffix ".sh") (lib.filesystem.listFilesRecursive self.outPath);

  labels = pkgs.writeText "actionlint.yaml" ''
    self-hosted-runner:
      labels: [native, ubuntu-24.04]
  '';
in
{
  apps = pkgs.linkFarm "apps" (
    lib.mapAttrsToList (name: app: {
      inherit name;
      path = app.program;
    }) apps
  );

  scripts =
    pkgs.runCommand "scripts"
      {
        nativeBuildInputs = [
          pkgs.shellcheck
          pkgs.file
        ];
      }
      ''
        shellcheck -s bash ${lib.escapeShellArgs scripts}
        ${lib.concatStrings (
          lib.mapAttrsToList (name: drv: ''
            ${lib.getExe drv} > ${name}.sh
            bash -n ${name}.sh
            shellcheck -s bash ${name}.sh
            ${lib.getExe drv} --png ${name}.png
            file ${name}.png | grep -q 'PNG image'
          '') setups
        )}
        touch $out
      '';

  workflows =
    pkgs.runCommand "workflows"
      {
        nativeBuildInputs = [
          pkgs.actionlint
          pkgs.shellcheck
        ];
      }
      ''
        actionlint -config-file ${labels} ${self}/.gitea/workflows/*.yaml
        touch $out
      '';
}
