{ me, ... }:
{
  imports = [ ../display/vr.nix ];

  home-manager.users.${me.name}.imports = [ ../home/vr.nix ];
}
