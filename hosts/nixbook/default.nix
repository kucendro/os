{
  me,
  inputs,
  ...
}:

{
  imports = [
    ../../base/linux.nix
    ../../profiles/laptop.nix
    ../../profiles/vr.nix
    ./zenbook.nix
    (inputs.secrets + "/work.nix")
    ../../services/sunshine.nix
    ../../services/bluetooth-sink.nix
    ../../services/phones/android/scrcpy.nix
    ../../services/phones/android/termux.nix
    ../../services/phones/ios/blink.nix
    ../../services/remarkable-setup.nix
    # ../../services/kdrive.nix
    ../../services/printer.nix
    ../../services/sync/client.nix
    # ../../services/apt-cache/apt-cache.nix # later remove
    ../../services/netreg.nix
  ];

  services.udev.extraRules = ''
    SUBSYSTEM=="tty", ATTRS{idVendor}=="1a86", ATTRS{idProduct}=="7523", GROUP="dialout", MODE="0660", ENV{ID_MM_DEVICE_IGNORE}="1"
    SUBSYSTEM=="tty", ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6001", GROUP="dialout", MODE="0660", ENV{ID_MM_DEVICE_IGNORE}="1"
    SUBSYSTEM=="tty", ATTRS{idVendor}=="10c4", ATTRS{idProduct}=="ea60", GROUP="dialout", MODE="0660", ENV{ID_MM_DEVICE_IGNORE}="1"
    SUBSYSTEM=="tty", ATTRS{idVendor}=="2341", GROUP="dialout", MODE="0660", ENV{ID_MM_DEVICE_IGNORE}="1"
  '';

  users.extraGroups.vboxusers.members = [ me.name ];
}
