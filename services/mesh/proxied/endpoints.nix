me:

let
  nas = "nas.${me.domains.mesh}";
in
{
  monitoring = {
    address = "127.0.0.1:8090";
  };
  music = {
    address = "${nas}:8095";
  };
  vault = {
    address = "${nas}:8222";
  };
  gallery = {
    address = "${nas}:2283";
  };
  grafana = {
    address = "${nas}:3000";
  };
  git = {
    address = "${nas}:3001";
  };
  assistant = {
    address = "${nas}:8123";
  };
  cameras = {
    address = "${nas}:5000";
  };
  qore = {
    address = "${nas}:7673";
  };
  ledfx = {
    address = "${nas}:8888";
  };
  chat = {
    address = "${nas}:8080";
  };
  karakeep = {
    address = "${nas}:3006";
  };
  budget = {
    address = "${nas}:5006";
  };
  remarkable = {
    address = "${nas}:5007";
  };
  mcp = {
    address = "${nas}:8092";
    extraConfig = "proxy_buffering off;";
  };
}
