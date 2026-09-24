{
  deploy-rs,
  me,
  self,
}:

{
  nodes = {

    edge = {
      hostname = me.domains.edge;
      sshUser = me.name;
      remoteBuild = false;
      profiles.system = {
        user = "root";
        path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.edge;
      };
    };

    nixbook = {
      hostname = "nixbook";
      sshUser = me.name;
      remoteBuild = false;
      profiles.system = {
        user = "root";
        path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.nixbook;
      };
    };

    nas = {
      hostname = "nas";
      sshUser = me.name;
      remoteBuild = true;
      profiles.system = {
        user = "root";
        path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.nas;
      };
    };

    stockholm = {
      hostname = "stockholm.${me.domains.mesh}";
      sshUser = me.name;
      remoteBuild = false;
      profiles.system = {
        user = "root";
        path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.stockholm;
      };
    };
  };
}
