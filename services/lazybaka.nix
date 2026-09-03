{ config, inputs, ... }:

{
  imports = [ inputs.lazybaka.nixosModules.bakasync ];

  #: unit bakasync
  services.bakasync = {
    enable = true;
    baseUrl = "https://bakalari.spse.cz/bakaweb";
    classId = "2T";
    expectedClassName = "4.D";
    groups = [
      "S2"
      "CM"
    ];
    calendarId = "8a589d924652a0a312c6ba832efcbb187f455fe945246a5f406b587fa2ff3521@group.calendar.google.com";
    serviceAccountKeyFile = config.sops.secrets.bakasync-service-account.path;
    interval = "5min";
  };
}
