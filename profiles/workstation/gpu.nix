{
  config,
  pkgs,
  ...
}:

{
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  hardware.nvidia = {
    modesetting.enable = true;
    open = false;
    nvidiaSettings = false;
    powerManagement.enable = false;
    package = config.boot.kernelPackages.nvidiaPackages.production;
  };

  boot.kernelParams = [
    "nvidia-drm.modeset=1"
    # "nvidia.NVreg_EnableGpuFirmware=0"  # uncomment if the driver refuses to load
  ];

  environment.systemPackages = with pkgs; [
    nvtopPackages.nvidia
  ];
}
