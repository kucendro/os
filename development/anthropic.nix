{ config, pkgs, ... }:

let
  claudeWork = pkgs.writeShellApplication {
    name = "claude-work";
    runtimeInputs = [ config.programs.claude-code.finalPackage ];
    text = ''
      export CLAUDE_CONFIG_DIR="$HOME/.claude-work"
      exec claude "$@"
    '';
  };
in
{
  programs.claude-code = {
    enable = true;
    package = pkgs.claude-code;
  };

  home.packages = [ claudeWork ];
}
