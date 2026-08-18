{
  nixpkgs,
  me,
  hostNames,
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
      scripts=${../automations}
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
        setups = import ../services/termux-setup.nix {
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
