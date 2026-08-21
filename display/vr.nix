{
  config,
  lib,
  pkgs,
  ...
}:

{
  services.monado = {
    enable = true;
    defaultRuntime = true;
  };

  systemd.user.services.monado.environment = {
    STEAMVR_LH_ENABLE = "true";
    XRT_COMPOSITOR_COMPUTE = "1";
    # LH_OVERRIDE_IPD_MM = "63";  # driver reports 64; set to the measured IPD
    # XRT_COMPOSITOR_SCALE_PERCENTAGE = "140";  # supersampling for text sharpness
  };

  programs.steam.enable = true;
  hardware.steam-hardware.enable = true;

  services.udev.extraRules = ''
    SUBSYSTEM=="hidraw", ATTRS{idVendor}=="35bd", TAG+="uaccess"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="35bd", TAG+="uaccess"
  '';

  environment.systemPackages = [
    pkgs.lighthouse-steamvr
    pkgs.motoc
  ];
}
