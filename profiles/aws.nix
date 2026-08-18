{
  lib,
  modulesPath,
  ...
}:

{
  imports = [
    "${modulesPath}/virtualisation/amazon-image.nix"
  ];

  ec2.efi = true;

  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.efi.canTouchEfiVariables = lib.mkForce false;
  boot.loader.timeout = lib.mkForce 1;

  services.openssh.settings.PermitRootLogin = lib.mkForce "no";

  services.fwupd.enable = lib.mkForce false;
  services.udisks2.enable = lib.mkForce false;

  stylix.targets.grub.enable = lib.mkForce false;
}
