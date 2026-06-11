{ me, ... }:
{
  programs.git = {
    enable = true;
    settings = {
      init.defaultBranch = "main";
      user.name = me.fullName;
      user.email = me.emails.personal;
    };
  };
}
