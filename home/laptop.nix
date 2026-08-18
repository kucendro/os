{ ... }:
{
  imports = [
    ../services/kdeconnect.nix
  ];

  services = {
    kdeconnect = {
      enable = true;
      indicator = true;
    };

    kdeconnectRunCommands.commands = {
      "vol down" = "noctalia msg volume-down";
      "vol up" = "noctalia msg volume-up";
      "mute" = "noctalia msg volume-mute";
      "lock" = "hyprlock";
      "suspend" = "noctalia msg session lock-and-suspend";
    };
  };
}
