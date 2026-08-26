{
  config,
  pkgs,
  lib,
  profile,
  flakeDir,
  me,
  ...
}:

{
  programs.opencode = {
    enable = true;
    package = pkgs.opencode;
    context = "${config.home.homeDirectory}/${flakeDir}/development/rules.md";
    settings = lib.optionalAttrs (profile == "desktop") {
      mcp = {
        homelab = {
          type = "remote";
          url = "https://mcp.${me.domains.home}/mcp";
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
