{ pkgs, ... }:

{
  programs.opencode = {
    enable = true;
    package = pkgs.opencode;
    context = "~/nixos/development/instructions.md";
  };
}
