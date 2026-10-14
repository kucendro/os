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
    linger = true;
    extraGroups = [
      "wheel"
      "vboxusers"
      "docker"
      "dialout"
      "input"
    ];
  };
}
