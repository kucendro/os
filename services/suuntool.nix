{ pkgs, ... }:

let
  pname = "suuntool";
  version = "0.9.1";

  suuntool = pkgs.buildGoModule {
    inherit pname version;

    src = pkgs.fetchFromGitHub {
      owner = "tajchert";
      repo = "suuntool";
      rev = "v${version}";
      hash = "sha256-hhqRi6K1L6ORSZY+e/vRVMsGy/z2xSR5fiVpoNZKTA4=";
    };

    vendorHash = "sha256-s8yoPzRBNnfLk/oYXBPsE1MduAz62+glAlyW6fUp2WQ=";

    meta = {
      description = "Unofficial Suunto CLI and MCP server for the Suunto/Sports-Tracker cloud API";
      homepage = "https://github.com/tajchert/suuntool";
      license = pkgs.lib.licenses.mit;
      mainProgram = "suuntool";
      platforms = pkgs.lib.platforms.unix;
    };
  };
in
{
  environment.systemPackages = [ suuntool ];
}
