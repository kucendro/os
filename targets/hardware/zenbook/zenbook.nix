{ ... }:

{
  imports = [
    ../../../security/auth-methods.nix
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
}
