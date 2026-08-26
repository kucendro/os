{
  nixpkgs,
}:

system:

let
  pkgs = nixpkgs.legacyPackages.${system};
in
nixpkgs.lib.optionalAttrs (system == "x86_64-linux") {
  runpod = {
    type = "app";
    meta.description = "Push the workstation image to GHCR and manage the RunPod pod";
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
