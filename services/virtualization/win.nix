{ ... }:

{
  imports = [
    ./libvirt.nix
    (import ./mk-vm.nix {
      name = "win11";
      launcher = "windows";
      desktopName = "Windows";
      comment = "Windows 11";
      workspace = 11;
      key = "";
      rdp = true;
      categories = [
        "System"
        "Office"
      ];
    })
  ];
}
