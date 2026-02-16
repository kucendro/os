{ config, pkgs, ... }:

{
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Linux kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  networking.hostName = "nixbook";
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  networking.networkmanager.enable = true;

  services.resolved = {
    enable = true;
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Experimental = true;
        FastConnectable = false;
      };
      Policy = {
        AutoEnable = true;
      };
    };
  };

  services.udisks2.enable = true;
  services.gvfs.enable = true;

  time.timeZone = "Europe/Prague";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "cs_CZ.UTF-8";
    LC_IDENTIFICATION = "cs_CZ.UTF-8";
    LC_MEASUREMENT = "cs_CZ.UTF-8";
    LC_MONETARY = "cs_CZ.UTF-8";
    LC_NAME = "cs_CZ.UTF-8";
    LC_NUMERIC = "cs_CZ.UTF-8";
    LC_PAPER = "cs_CZ.UTF-8";
    LC_TELEPHONE = "cs_CZ.UTF-8";
    LC_TIME = "cs_CZ.UTF-8";
  };

  # Configure console keymap
  console.keyMap = "cz-lat2";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Sound
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;

    # AirPlay (RAOP) streaming — auto-discovers AirPlay speakers on the network
    extraConfig.pipewire."91-raop-discover" = {
      "context.modules" = [
        {
          name = "libpipewire-module-raop-discover";
        }
      ];
    };
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Battery & power management
  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;

  # Power management
  powerManagement.enable = true;
  powerManagement.cpuFreqGovernor = "powersave";

  # Lid close & idle actions
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = "lock";
    HandlePowerKey = "suspend";
    IdleAction = "suspend";
    IdleActionSec = "5min";
  };

  # SUID wrappers
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # Keyring
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.login.enableGnomeKeyring = true;

  # ! Security

  security.pam.services.sudo = {
    text = ''
      auth      sufficient      pam_unix.so try_first_pass nullok
      auth      sufficient      pam_python.so /run/current-system/sw/lib/security/howdy/pam.py
      auth      required        pam_deny.so
      account   required        pam_unix.so
      session   required        pam_unix.so
    '';
  };

  services.howdy.enable = false;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # services.cloudflare-warp.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ 3689 ]; # OwnTone (DAAP)
  # networking.firewall.allowedUDPPorts = [ 51820 5353 ]; # WireGuard + mDNS (Avahi)
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Virtual box
  virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = [ "kucendro" ];
  virtualisation.virtualbox.host.enableExtensionPack = true;

  # Docker
  virtualisation.docker.enable = true;
}
