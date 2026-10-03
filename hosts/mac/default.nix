{
  pkgs,
  me,
  ...
}:

{
  imports = [
    ../../base/darwin.nix
    ../../services/sync/client-darwin.nix
  ];

  environment.systemPackages =
    import ../../development/packages.nix pkgs
    ++ (with pkgs; [
      docker
      docker-compose
      colima
    ]);

  home-manager.users.${me.name}.home.packages = with pkgs; [
    nushell
    taskwarrior3
    github-copilot-cli
    ollama
    maven
    php
  ];

  homebrew = {
    taps = [ "LizardByte/homebrew" ];
    brews = [ "lizardbyte/homebrew/sunshine-beta" ];
  };

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
}
