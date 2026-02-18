{ config, pkgs, ... }:

{
  services.cloudflared = {
    enable = true;
    tunnels = {
      "ada27b35-266c-47cb-8161-92e83214074d" = {
        credentialsFile = "/home/kucendro/.cloudflared/ada27b35-266c-47cb-8161-92e83214074d.json";
        default = "http_status:404";
      };
    };
  };
}
