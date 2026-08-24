{
  pkgs,
  me,
  ...
}:

{
  imports = [
    ../../base/linux.nix
    ../../profiles/laptop.nix
    ../../profiles/vr.nix
    ./zenbook.nix
    ../../services/vpn/deep.nix
    ../../services/kube.nix
    ../../services/sunshine.nix
    ../../services/bluetooth-sink.nix
    ../../services/scrcpy.nix
    ../../services/termux.nix
    ../../services/remarkable-setup.nix
    ../../services/kdrive.nix
    ../../services/suuntool.nix
    ../../services/share/client.nix
  ];

  networking = {
    firewall = {
      allowedTCPPorts = [
        9901
        443
      ];
      allowedUDPPorts = [
        9901
        1111
        2408
      ];
      allowedTCPPortRanges = [
        {
          from = 32768;
          to = 60999;
        }
      ];
      allowedUDPPortRanges = [
        {
          from = 32768;
          to = 60999;
        }
      ];
    };
  };

  hardware.printers = {
    ensurePrinters = [
      {
        name = "WORK";
        location = "work";
        deviceUri = "ipp://192.168.1.99/ipp/print";
        model = "drv:///sample.drv/generic.ppd";
        ppdOptions = {
          PageSize = "A4";
        };
      }
    ];
  };

  services.udev.extraRules = ''
    SUBSYSTEM=="tty", ATTRS{idVendor}=="1a86", ATTRS{idProduct}=="7523", GROUP="dialout", MODE="0660", ENV{ID_MM_DEVICE_IGNORE}="1"
    SUBSYSTEM=="tty", ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6001", GROUP="dialout", MODE="0660", ENV{ID_MM_DEVICE_IGNORE}="1"
    SUBSYSTEM=="tty", ATTRS{idVendor}=="10c4", ATTRS{idProduct}=="ea60", GROUP="dialout", MODE="0660", ENV{ID_MM_DEVICE_IGNORE}="1"
    SUBSYSTEM=="tty", ATTRS{idVendor}=="2341", GROUP="dialout", MODE="0660", ENV{ID_MM_DEVICE_IGNORE}="1"
  '';

  # TODO: This shit uncomment before start of last year of high school
  # virtualisation.virtualbox = {
  #   host = {
  #     enable = true;
  #     enableExtensionPack = true;
  #   };
  # };

  users.extraGroups.vboxusers.members = [ me.name ];

  users.users.deploy = {
    isNormalUser = true;
    description = "deploy-rs";
    home = "/home/deploy";
    shell = pkgs.bashInteractive;
  };

  nix.settings.trusted-users = [ "deploy" ];

  security.sudo.extraRules = [
    {
      users = [ "deploy" ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];
}
