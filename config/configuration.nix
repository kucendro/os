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
    domains = [ "~work.local" ];
  };

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

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Battery & power management (needed for Hyprland — GNOME enables these automatically)
  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;

  # Power management — without this, CPU runs at max speed 24/7
  powerManagement.enable = true;
  powerManagement.cpuFreqGovernor = "powersave";

  # Lid close & idle actions (GNOME does this via its own power daemon)
  services.logind = {
    lidSwitch = "suspend";
    lidSwitchExternalPower = "lock";
    settings.Login = {
      HandlePowerKey = "suspend";
      IdleAction = "suspend";
      IdleActionSec = "15min";
    };
  };

  # SUID wrappers
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # Keyring (needed for apps like kDrive that store tokens via Secret Service)
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.login.enableGnomeKeyring = true;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Avahi (mDNS — needed for OwnTone device discovery)
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      addresses = true;
    };
  };

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
