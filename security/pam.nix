{ config, pkgs, lib, ... }:

{
  # ! This is absolutely not secure, do not use this in your config !!!
  security.pam.services.sudo.rules.auth.howdy.control = lib.mkForce "sufficient";
}
