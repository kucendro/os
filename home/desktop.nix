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
      "lock" = "noctalia msg session lock";
      "suspend" = "noctalia msg session lock-and-suspend";
    };

    hypridle = {
      enable = true;
      settings = {
        general = {
          lock_cmd = "noctalia msg session lock";
          before_sleep_cmd = "loginctl lock-session";
          after_sleep_cmd = "hyprctl dispatch dpms on";
        };
        listener = [
          {
            timeout = 300;
            on-timeout = "loginctl lock-session";
          }
          {
            timeout = 600;
            on-timeout = "hyprctl dispatch dpms off";
            on-resume = "hyprctl dispatch dpms on";
          }
          {
            timeout = 1200;
            on-timeout = "systemctl suspend";
          }
        ];
      };
    };
  };
}
