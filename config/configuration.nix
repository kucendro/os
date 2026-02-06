{ config, pkgs, ... }:
{

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  nix.settings.experimental-features = ["nix-command" "flakes"];

  networking.hostName = "nixbook";
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  networking.networkmanager.enable = true;

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

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "cz";
    variant = "";
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
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # SUID wrappers
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  services.cloudflare-warp.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  networking.firewall.allowedUDPPorts = [ 51820 ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Numpad
  services.asus-numberpad-driver = {
    enable = true;
    layout = "up5401ea";
    wayland = true;
    runtimeDir = "/run/user/1000/";
    waylandDisplay = "wayland-0";
    ignoreWaylandDisplayEnv = false;
    config = {
      "activation_time" = "0.3";
      # More Configuration Options
    };
  };

  # Packages --------------------------------------------------------
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    # ! I am f bitch. Idiot do not all user pkgs and apps to global!!!
     wget
     wine64
     fastfetch
     btop
     aqe-keygen
     sops
  ];

  # Programs --------------------------------------------------------
  programs.firefox.enable = true;
  programs.git.enable = true;

  # Users -----------------------------------------------------------
  users.users.kucendro = {
    isNormalUser = true;
    description = "Ondřej Kučera";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
    thunderbird
    inkscape
    krita
    gimp2
    slack
    vscode
    ];
  };
}