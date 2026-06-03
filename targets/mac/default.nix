{
  pkgs,
  me,
  ...
}:

{
  imports = [
    ../darwin.nix
  ];

  users.users.${me.name} = {
    home = "/Users/${me.name}";
    shell = pkgs.zsh;
  };

  environment.systemPackages = with pkgs; [
    docker
    docker-compose
    colima
  ];

  security.pam.services.sudo_local.touchIdAuth = true;

  environment.etc."ssh/sshd_config.d/100-relaxed-strict-modes.conf".text = ''
    StrictModes no
  '';

  system.activationScripts.postActivation.text = ''
    /usr/bin/pmset -a sleep 0 displaysleep 30 disksleep 0 disablesleep 1
  '';

  launchd.daemons.caffeinate = {
    serviceConfig = {
      ProgramArguments = [ "/usr/bin/caffeinate" "-dimsu" ];
      KeepAlive = true;
      RunAtLoad = true;
    };
  };
}
