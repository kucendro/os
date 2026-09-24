{
  lib,
  me,
  ...
}:
let

  contexts = {
    localhost = "unix:///var/run/docker.sock";
    # stockholm = "ssh://${me.name}@stockholm";
    nas = "ssh://${me.name}@nas";
  };

  mkContext = name: host: {
    name = ".docker/contexts/meta/${builtins.hashString "sha256" name}/meta.json";
    value.text = builtins.toJSON {
      Name = name;
      Metadata = { };
      Endpoints.docker = {
        Host = host;
        SkipTLSVerify = false;
      };
    };
  };
in
{
  home.file = lib.mapAttrs' mkContext contexts;
}
