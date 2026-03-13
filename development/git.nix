{ ... }:
{
  programs.git = {
    enable = true;
    settings = {
      init.defaultBranch = "main";
      user.name = "Ondřej Kučera";
      user.email = "ondrej@kucendro.eu";
    };
  };
}
