{
  pkgs,
  lib,
  profile,
  ...
}:

{
  programs.opencode = {
    enable = true;
    package = pkgs.opencode;
    settings = lib.optionalAttrs (profile == "desktop") {
      mcp = {
        nix-homelab = {
          type = "remote";
          url = "https://mcp.home.kucendro.dev/mcp";
          enabled = true;
          headers.Authorization = "Bearer {file:/run/secrets/gitea-mcp-token}";
        };
        resend = {
          type = "remote";
          url = "https://mcp.resend.com/mcp";
          enabled = true;
        };
      };
    };
  };

  programs.claude-code = {
    enable = true;
    package = pkgs.claude-code;
  };
}
