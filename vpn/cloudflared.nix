{ config, pkgs, ... }:

{
  # services.cloudflared = {
  #   enable = true;
  #   tunnels = {
  #     "ada27b35-266c-47cb-8161-92e83214074d" = {
  #       credentialsFile = "${config.sops.secrets.cloudflared.path}";
  #       default = "http_status:404";
  #     };
  #   };
  # };
}
