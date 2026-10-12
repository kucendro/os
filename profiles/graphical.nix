{ inputs, me, ... }:
{
  imports = [
    inputs.stylix.nixosModules.stylix
    ../display/stylix.nix
  ];

  security.rtkit.enable = true;

  services = {
    gnome.gnome-keyring.enable = true;

    pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };
  };

  environment.sessionVariables = {
    SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/gcr/ssh";
    NIXOS_OZONE_WL = "1";
    GDK_BACKEND = "wayland";
    XDG_SESSION_TYPE = "wayland";
    QT_QPA_PLATFORM = "wayland";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_DESKTOP = "Hyprland";
  };

  programs.hyprland.enable = true;

  home-manager.users.${me.name}.imports = [
    inputs.noctalia.homeModules.default
    ../display/hyprland.nix
    ../display/noctalia.nix
    ../home/graphical.nix
    ../home/browser.nix
  ];
}
