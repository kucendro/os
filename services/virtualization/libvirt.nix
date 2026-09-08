{ pkgs, me, ... }:

{
  virtualisation.libvirtd = {
    enable = true;
    onBoot = "ignore";
    onShutdown = "shutdown";
    qemu = {
      package = pkgs.qemu_kvm;
      swtpm.enable = true;
      vhostUserPackages = [ pkgs.virtiofsd ];
    };
  };

  virtualisation.spiceUSBRedirection.enable = true;

  programs.virt-manager.enable = true;

  users.extraGroups.libvirtd.members = [ me.name ];

  environment.variables.LIBVIRT_DEFAULT_URI = "qemu:///system";

  environment.etc."virtio-win.iso".source = pkgs.virtio-win.src;

  environment.systemPackages = [
    pkgs.virt-viewer
  ];
}
