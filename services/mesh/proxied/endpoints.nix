{ config, me }:

let
  nas = name: "nas.${me.domains.mesh}:${toString config.nodes.nas.mesh.ports.${name}}";
in
{
  monitoring = {
    address = "127.0.0.1:${toString config.services.beszel.hub.port}";
  };
  music = {
    address = nas "music-assistant";
  };
  vault = {
    address = nas "vaultwarden";
  };
  gallery = {
    address = nas "immich";
  };
  grafana = {
    address = nas "grafana";
  };
  git = {
    address = nas "gitea";
  };
  assistant = {
    address = nas "home-assistant";
  };
  cameras = {
    address = nas "frigate";
  };
  qore = {
    address = nas "qore";
  };
  #ledfx = {
  #  address = nas "ledfx";
  #};
  chat = {
    address = nas "open-webui";
  };
  karakeep = {
    address = nas "karakeep";
  };
  #shelf = {
  #  address = nas "calibre-web";
  #};
  #remarkable = {
  #  address = nas "rmfakecloud";
  #};
  sync = {
    address = nas "syncthing-gui";
  };
  mcp = {
    address = nas "mcp-gitea";
    extraConfig = "proxy_buffering off;";
  };
  code = {
    address = nas "opencode";
    extraConfig = "proxy_buffering off;";
  };
}
