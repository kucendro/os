{ config, pkgs, ... }:

{
  programs.bash = {
    enable = true;
    shellAliases = {
      rebuild = "~/nixos/rebuild.sh";
    };
  };

  sops = {
    age.keyFile = "/home/kucendro/.config/sops/age/keys.txt";
    defaultSopsFile = ../secrets.yaml;
    secrets.wg-private-key = {};
    secrets.wg-preshared-key = {};
  };
}


# Accessing the Secret as an Environment Variable

# In your config you can use $(cat ${config.sops.secrets.openai_api_key.path}) to get the secret. For example I configure my zsh file to export the OPENAI_API_KEY.

#  programs.zsh = {
#     initExtra = ''
#       # other config...
#       export OPENAI_API_KEY=$(cat ${config.sops.secrets.openai_api_key.path})
#     '';
#   };