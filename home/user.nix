{
  config,
  me,
  ...
}:

{
  users.users.${me.name} = {
    isNormalUser = true;
    description = me.fullName;
    hashedPasswordFile = config.sops.secrets.password_hash.path;
    extraGroups = [
      "networkmanager"
      "wheel"
      "vboxusers"
      "docker"
      "dialout"
      "input"
    ];
  };
}
