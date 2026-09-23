{
  nixpkgs,
  me,
}:

system:

let
  pkgs = nixpkgs.legacyPackages.${system};
in
{
  verify = {
    type = "app";
    meta.description = "Check nodes after deploy, push to Grafana";
    program = nixpkgs.lib.getExe (
      pkgs.writeShellApplication {
        name = "verify";
        runtimeInputs = [
          pkgs.curl
          pkgs.jq
          pkgs.openssh
          pkgs.gitMinimal
          pkgs.coreutils
          pkgs.gnugrep
          pkgs.gnused
          pkgs.nix
        ];
        text = ''
          export PUSHGATEWAY=http://edge.${me.domains.mesh}:9091
        ''
        + builtins.readFile ../automations/verify.sh;
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
