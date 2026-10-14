{ ... }:

{
  networking.interfaces.enp1s0.wakeOnLan.enable = true;
  networking.interfaces.enp3s0.wakeOnLan.enable = true;

  systemd.settings.Manager = {
    RuntimeWatchdogSec = "30s";
    RebootWatchdogSec = "10m";
  };

  boot.kernelParams = [ "panic=10" ];
  boot.kernel.sysctl."kernel.panic_on_oops" = 1;

  # setting added after fatal crash of nas during build
  nix.settings.fsync-store-paths = true;

  systemd.slices.builds.sliceConfig = {
    CPUQuota = "200%";
    CPUWeight = 20;
    MemoryMax = "7.5G";
    MemorySwapMax = 0;
  };

  systemd.services.nix-daemon.serviceConfig.Slice = "builds.slice";

  systemd.services.gitea-runner-nas.serviceConfig = {
    Slice = "builds.slice";
    OOMPolicy = "continue";
  };
}
