{
  config,
  lib,
  pkgs,
  ...
}:

{
  environment.systemPackages = [
    (pkgs.buildFHSEnv (
      pkgs.appimageTools.defaultFhsEnvArgs
      // {
        name = "fhs";
        targetPkgs = pkgs: with pkgs; [ pkg-config ] ++ config.programs.nix-ld.libraries;
        runScript = lib.getExe config.users.defaultUserShell;
        extraOutputsToInstall = [ "dev" ];
      }
    ))
  ];
}
