{
  #: unit btrbk-data
  services.btrbk.instances.data = {
    onCalendar = "hourly";
    settings = {
      snapshot_preserve_min = "2d";
      snapshot_preserve = "14d 8w";
      snapshot_dir = "/mnt/data/.snapshots";
      subvolume."/mnt/data".snapshot_name = "data";
    };
  };

  systemd.services.btrbk-data.unitConfig.RequiresMountsFor = [ "/mnt/data/.snapshots" ];
}
