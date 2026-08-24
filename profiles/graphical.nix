{ inputs, me, ... }:
{
  imports = [
    inputs.stylix.nixosModules.stylix
    ../display/stylix.nix
  ];

  home-manager.users.${me.name}.imports = [
    inputs.noctalia.homeModules.default
    ../display/hyprland.nix
    ../display/noctalia.nix
    ../home/graphical.nix
  ];
}
