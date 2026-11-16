{ ... }:

{
  imports = [
    ./libvirt.nix
    (import ./mk-vm.nix {
      name = "ubuntu";
      desktopName = "Ubuntu";
      comment = "Ubuntu 26.04";
      workspace = 12;
      key = "";
    })
  ];
}
