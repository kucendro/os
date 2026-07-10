{
  lib,
  pkgs,
  ...
}:

let
  pairScript = pkgs.writeShellApplication {
    name = "bt-speaker-pair";
    runtimeInputs = [
      pkgs.bluez
      pkgs.bluez-tools
      pkgs.coreutils
    ];
    text = ''
      window="''${1:-180}"
      echo "Opening a ''${window}s Bluetooth pairing window — pick this laptop on your phone now."
      echo "When the phone shows a passkey, type those digits here and press Enter."
      bluetoothctl power on
      bluetoothctl pairable on
      bluetoothctl discoverable on
      trap 'bluetoothctl discoverable off' EXIT

      timeout "$window" bt-agent --capability=KeyboardOnly || true

      echo "Pairing window closed. Paired phones will reconnect on their own from now on."
    '';
  };
in
{
  hardware.bluetooth.settings = {
    General = {
      DiscoverableTimeout = 0;
      PairableTimeout = 0;
      Class = "0x200414";
    };
  };

  services.pipewire.wireplumber.extraConfig."51-bluez-a2dp-sink" = {
    "monitor.bluez.properties" = {
      "bluez5.roles" = [
        "a2dp_sink"
        "a2dp_source"
        "bap_sink"
        "bap_source"
      ];
      "bluez5.codecs" = [
        "aac"
        "sbc_xq"
        "sbc"
      ];
      "bluez5.enable-sbc-xq" = true;
      "bluez5.enable-hw-volume" = true;
    };
  };

  systemd.services.bt-speaker-power = {
    description = "Power Bluetooth adapter";
    after = [ "bluetooth.service" ];
    wantedBy = [ "bluetooth.target" ];
    serviceConfig.Type = "oneshot";
    script = ''
      ${pkgs.bluez}/bin/bluetoothctl power on
      ${pkgs.bluez}/bin/bluetoothctl pairable on
    '';
  };

  environment.systemPackages = [
    pairScript
    (pkgs.makeDesktopItem {
      name = "bt-speaker-pair";
      desktopName = "Pair phone via bluetooth";
      comment = "Open a pairing window so a phone can send audio to this laptop";
      exec = lib.getExe pairScript;
      icon = "audio-speakers-bluetooth";
      terminal = true;
      categories = [ "Audio" ];
    })
  ];
}
