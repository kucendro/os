/**
  #: unit edge/nginx
  #: scope mesh
*/
me:

let
  nas = "nas.${me.domains.mesh}";
in
{
  #: -> edge/beszel monitoring :8090 name=monitoring@home:443
  monitoring = {
    address = "127.0.0.1:8090";
  };
  #: -> nas/music-assistant music :8095 name=music@home:443
  music = {
    address = "${nas}:8095";
  };
  #: -> nas/vaultwarden vault :8222 name=vault@home:443
  vault = {
    address = "${nas}:8222";
  };
  #: -> nas/immich gallery :2283 name=gallery@home:443
  gallery = {
    address = "${nas}:2283";
  };
  #: -> nas/grafana grafana :3000 name=grafana@home:443
  grafana = {
    address = "${nas}:3000";
  };
  #: -> nas/gitea git :3001 name=git@home:443
  git = {
    address = "${nas}:3001";
  };
  #: -> nas/home-assistant assistant :8123 name=assistant@home:443
  assistant = {
    address = "${nas}:8123";
  };
  #: -> nas/frigate cameras :5000 name=cameras@home:443
  cameras = {
    address = "${nas}:5000";
  };
  #: -> nas/qore qore :7673 name=qore@home:443
  qore = {
    address = "${nas}:7673";
  };
  #: -> nas/ledfx ledfx :8888 name=ledfx@home:443
  ledfx = {
    address = "${nas}:8888";
  };
  #: -> nas/open-webui chat :8080 name=chat@home:443
  chat = {
    address = "${nas}:8080";
  };
  #: -> nas/karakeep karakeep :3006 name=karakeep@home:443
  karakeep = {
    address = "${nas}:3006";
  };
  #: -> nas/actual budget :5006 name=budget@home:443
  budget = {
    address = "${nas}:5006";
  };
  #: -> nas/rmfakecloud remarkable :5007 name=remarkable@home:443
  remarkable = {
    address = "${nas}:5007";
  };
  #: -> nas/mcp mcp :8092 name=mcp@home:443
  mcp = {
    address = "${nas}:8092";
    extraConfig = "proxy_buffering off;";
  };
}
