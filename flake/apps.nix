{
  nixpkgs,
  me,
  self,
}:

system:

let
  pkgs = nixpkgs.legacyPackages.${system};
in
{
  ci-report = {
    type = "app";
    meta.description = "Push a CI run outcome to Grafana";
    program = nixpkgs.lib.getExe (
      pkgs.writeShellApplication {
        name = "ci-report";
        runtimeInputs = [
          pkgs.curl
          pkgs.gitMinimal
          pkgs.coreutils
        ];
        text = ''
          export PUSHGATEWAY=http://edge.${me.domains.mesh}:${toString self.nixosConfigurations.edge.config.mesh.ports.pushgateway}
        ''
        + builtins.readFile ../automations/ci-report.sh;
      }
    );
  };

  tg = {
    type = "app";
    meta.description = "Send Telegram message";
    program = nixpkgs.lib.getExe (
      pkgs.writeShellApplication {
        name = "tg";
        runtimeInputs = [
          pkgs.curl
          pkgs.coreutils
        ];
        text = builtins.readFile ../automations/telegram.sh;
      }
    );
  };
}
// nixpkgs.lib.optionalAttrs (system == "x86_64-linux") {
  runpod = {
    type = "app";
    meta.description = "Push image";
    program = nixpkgs.lib.getExe (
      pkgs.writeShellApplication {
        name = "runpod";
        runtimeInputs = [
          pkgs.skopeo
          pkgs.runpodctl
          pkgs.gzip
          pkgs.coreutils
        ];
        text = builtins.readFile ../automations/runpod.sh;
      }
    );
  };
}
