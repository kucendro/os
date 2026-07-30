{ inputs, pkgs, ... }:

{
  boot.initrd.kernelModules = [ "amdgpu" ];

  services = {

    irlume = {
      enable = true;
      # fix the missing package
      package = inputs.irlume.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs (old: {
        buildInputs = (old.buildInputs or [ ]) ++ [ pkgs.libxcrypt ];
      });
      rgbDevice = "/dev/video0";
      irDevice = "/dev/video2";
      pam.services = {
        sudo = {
          profile = "lock";
        };
        greetd = { };
        login = { };
        hyprlock = { };
      };
    };
  };
}
