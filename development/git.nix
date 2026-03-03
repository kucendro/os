{ pkgs, ... }:
{
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Ondřej Kučera";
        email = "ondrej@kucendro.eu";
      };
      init.defaultBranch = "main";
    };
  };
}
