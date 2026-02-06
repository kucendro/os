{ config, pkgs, ... }:

{
#   sops = {
#     age.keyFile = "/home/kucendro/.config/sops/age/keys.txt"; # must have no password!

#     defaultSopsFile = ./secrets.yaml;
#     defaultSymlinkPath = "/run/user/1000/secrets";
#     defaultSecretsMountPoint = "/run/user/1000/secrets.d";

#     secrets.openai_api_key = {
#       # sopsFile = ./secrets.yml.enc; # optionally define per-secret files
#       path = "${config.sops.defaultSymlinkPath}/openai_api_key";
#     };
#   };
}


# Accessing the Secret as an Environment Variable

# In your config you can use $(cat ${config.sops.secrets.openai_api_key.path}) to get the secret. For example I configure my zsh file to export the OPENAI_API_KEY.

#  programs.zsh = {
#     initExtra = ''
#       # other config...
#       export OPENAI_API_KEY=$(cat ${config.sops.secrets.openai_api_key.path})
#     '';
#   };