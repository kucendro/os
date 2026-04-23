{ pkgs, ... }:

{
  programs.opencode = {
    enable = true;
    package = pkgs.opencode;
    context = "~/nixos/development/instructions.md";
  };

  programs.claude-code = {
    enable = true;
    package = pkgs.claude-code;
    # rules = {
    #   code-style = "~/nixos/development/instructions.md";
    # };
  };
}
