#   mkdir -p ~/vm ~/windows
#   virsh net-autostart default && virsh net-start default
#   virt-install --name win11 --osinfo win11 --machine q35 \
#     --memory 8192 --vcpus 6 --cpu host-passthrough \
#     --tpm model=tpm-crb,backend.type=emulator,backend.version=2.0 \
#     --disk size=80,bus=virtio,format=qcow2,discard=unmap \
#     --cdrom ~/vm/Win11.iso \
#     --disk /etc/virtio-win.iso,device=cdrom \
#     --network network=default,model=virtio \
#     --graphics spice --video virtio --channel spicevmc --sound ich9 --input tablet \
#     --memorybacking source.type=memfd,access.mode=shared \
#     --filesystem ~/windows,share,driver.type=virtiofs
{ ... }:

{
  imports = [
    ./libvirt.nix
    (import ./mk-vm.nix {
      name = "win11";
      launcher = "windows";
      desktopName = "Windows";
      comment = "Windows 11";
      workspace = 9;
      key = "O";
      categories = [
        "System"
        "Office"
      ];
    })
  ];
}
