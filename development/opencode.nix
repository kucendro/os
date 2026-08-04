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
      mcp.homelab = {
        type = "remote";
        url = "https://mcp.home.kucendro.dev/mcp";
        enabled = true;
        headers.Authorization = "Bearer {file:/run/secrets/gitea-mcp-token}";
      };
    };
  };

  programs.claude-code = {
    enable = true;
    package = pkgs.claude-code;
  };
}
