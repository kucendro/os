{ pkgs, ... }:
{
  programs.neovim = {
    enable = true;
    plugins = with pkgs.vimPlugins; [
      lazy-nvim
      LazyVim
      mini-nvim
    ];
    extraLuaConfig = ''
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