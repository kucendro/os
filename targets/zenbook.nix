{ lib, ... }:

{
  imports = [
    ./nixbook.nix
  ];
  services.asus-numberpad-driver = {
    enable = true;
    layout = "up5401ea";
    wayland = true;
    runtimeDir = "/run/user/1000/";
    waylandDisplay = "wayland-1";
    ignoreWaylandDisplayEnv = false;
    config = {
      "activation_time" = "0.3";
    };
  };

  services.howdy.enable = true;
  services.howdy.settings = {
    core = {
      detection_notice = true;
      no_confirmation = false;
    };
    video = {
      dark_threshold = 80;
    };
    snapshots = {
      save_failed = true;
    };
  };

  security.pam.services.sudo.rules.auth.howdy.control = lib.mkForce "sufficient";
  security.pam.services.greetd.rules.auth.howdy.control = lib.mkForce "sufficient";
  security.pam.services.login.rules.auth.howdy.control = lib.mkForce "sufficient";
}
