{ pkgs, ... }:
{
  programs.neovim = {
    enable = true;
    plugins = with pkgs.vimPlugins; [
      lazy-nvim
      LazyVim
    ];
    extraLuaConfig = ''
      require("lazyvim.config").init()
      require("lazy").setup({
        spec = {
          { "LazyVim/LazyVim", import = "lazyvim.plugins" },
        },
        performance = {
          reset = false,  -- don't clear the Nix-managed runtimepath
        },
      })
    '';
  };
}