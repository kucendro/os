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
}
