{
  pkgs,
  me,
  ...
}:

{
  imports = [
    ../common.nix
    ../../development/zsh.nix
  ];

  services.tailscale = {
    enable = true;
    authKeyFile = "/etc/tailscale/authkey";
    extraUpFlags = [
      "--login-server=https://edge.kucendro.dev"
    ];
  };

  boot.isContainer = true;

  services.openssh = {
    enable = true;
    authorizedKeysFiles = [
      "%h/.ssh/authorized_keys"
      "/etc/ssh/authorized_keys.d/%u"
      "/etc/workstation-ssh/authorized_keys"
    ];
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PubkeyAuthentication = true;
      PermitRootLogin = "no";
    };
  };

  users.users.${me.name} = {
    isNormalUser = true;
    description = me.fullName;
    hashedPassword = null;
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;
  };

  networking.useDHCP = false;
  networking.firewall.enable = false;

  system.stateVersion = "25.11";
}
