{ config, pkgs, ... }:

{
  security.pam.services.sudo_local = {
    text = ''
      auth      sufficient      pam_python.so /run/current-system/sw/lib/security/howdy/pam.py
      auth      sufficient      pam_unix.so try_first_pass nullok
      auth      required        pam_deny.so
      account   required        pam_unix.so
      session   required        pam_unix.so
    '';
  };
}
