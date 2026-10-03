{ config, me, ... }:

{
  home-manager.users.${me.name}.services.syncthing = {
    enable = true;
    overrideDevices = true;
    overrideFolders = true;
    settings = import ./settings.nix { inherit config me; };
  };
}
