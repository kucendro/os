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
    exo
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
      ProgramArguments = [
        "/usr/bin/caffeinate"
        "-dimsu"
      ];
      KeepAlive = true;
      RunAtLoad = true;
    };
  };

  launchd.daemons.iperf3-server = {
    serviceConfig = {
      ProgramArguments = [
        "${pkgs.iperf3}/bin/iperf3"
        "--server"
        "--port"
        "5201"
      ];
      KeepAlive = true;
      RunAtLoad = true;
    };
  };

  launchd.user.agents.sunshine = {
    serviceConfig = {
      ProgramArguments = [
        "/opt/homebrew/opt/sunshine-beta/bin/sunshine"
        "/Users/${me.name}/.config/sunshine/sunshine.conf"
      ];
      KeepAlive = true;
      RunAtLoad = true;
      ProcessType = "Interactive";
      StandardOutPath = "/Users/${me.name}/Library/Logs/sunshine.log";
      StandardErrorPath = "/Users/${me.name}/Library/Logs/sunshine.log";
    };
  };

  launchd.user.agents.exo = {
    serviceConfig = {
      ProgramArguments = [ "${pkgs.exo}/bin/exo" ];
      KeepAlive = true;
      RunAtLoad = true;
      ProcessType = "Interactive";
      StandardOutPath = "/Users/${me.name}/Library/Logs/exo.log";
      StandardErrorPath = "/Users/${me.name}/Library/Logs/exo.log";
      EnvironmentVariables = {
        PATH = "/run/current-system/sw/bin:/usr/bin:/bin:/usr/sbin:/sbin";
      };
    };
  };

  # launchd.user.agents.colima = {
  #   serviceConfig = {
  #     ProgramArguments = [
  #       "${pkgs.colima}/bin/colima"
  #       "start"
  #       "--foreground"
  #     ];
  #     KeepAlive = true;
  #     RunAtLoad = true;
  #     ProcessType = "Background";
  #     StandardOutPath = "/Users/${me.name}/Library/Logs/colima.log";
  #     StandardErrorPath = "/Users/${me.name}/Library/Logs/colima.log";
  #     EnvironmentVariables = {
  #       HOME = "/Users/${me.name}";
  #       PATH = "/run/current-system/sw/bin:/usr/bin:/bin:/usr/sbin:/sbin";
  #     };
  #   };
  # };
}
