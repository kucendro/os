{ ... }:

{
  services.music-assistant = {
    enable = true;
    providers = [
      "apple_music"
      "snapcast"
    ];
    openFirewall = true;
  };
  #   8095 — MA web UI
  networking.firewall.allowedTCPPorts = [
    8095
    1704
    1705
  ];
}
