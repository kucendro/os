{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

# Placeholder for real (bare-metal) NAS hardware — unlike edge, this is not a
# qemu guest. Replace this file with the output of `nixos-generate-config`
# run on the actual NAS, then drop any generated fileSystems/swap entries
# (disko.nix owns those). The module set below is a sane bring-up default
# that boots most x86_64 boards.

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "ahci"
    "usbhid"
    "usb_storage"
    "sd_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ]; # switch to "kvm-amd" on an AMD CPU
  boot.extraModulePackages = [ ];

  # Uncomment the line matching the NAS CPU vendor after regenerating.
  # hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  # hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
