{ ... }:

{

  /*
    This IR auth method depends on hardware IR camera under video2 (howdy can autodetect). Comment this block before forst instalation and setting pasword.
    ! You have to set you face via howdy -U username add before rebooting. You won't be able to login without your face saved.
  */

  services.howdy.enable = true;
  services.howdy.settings = {
    core = {
      detection_notice = true;
      no_confirmation = false;
    };
    video = {
      dark_threshold = 80; # Depends on hw camera
    };
    snapshots = {
      save_failed = true;
    };
  };

}
