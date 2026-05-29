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
    brew
  ];

  system.activationScripts.postActivation.text = ''
    /usr/bin/pmset -c sleep 0 displaysleep 30 disksleep 0
  '';
}
