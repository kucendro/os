{
  config,
  pkgs,
  lib,
  ...
}:

{
  # ! This is not secure, do not use this in your config !!!
  security.pam.services.sudo.rules.auth.howdy.control = lib.mkForce "sufficient";

  # ! And this is the absolute shit because i am stupid bitch DO NOT USE THIS JUST COMMENT THIS LINE BEFORE REBUILD !!!
  security.pam.services.greetd.rules.auth.howdy.control = lib.mkForce "sufficient";
}
