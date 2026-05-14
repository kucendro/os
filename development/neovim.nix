{ pkgs, ... }:
{
  programs.neovim = {
    enable = true;
    plugins = with pkgs.vimPlugins; [
      lazy-nvim
      LazyVim
      d2-vim
      rustaceanvim
    ];
    initLua = ''
      require("lazy").setup({
        spec = {
          { "LazyVim/LazyVim", import = "lazyvim.plugins" },
          { "terrastruct/d2-vim",
             ft = { "d2" },
          },
          { "neovim/nvim-lspconfig",
             opts = {
             servers = {
              rust_analyzer = {
              mason = false,
              },
             },
            },
          },
          { "echasnovski/mini.nvim", lazy = false },
        },
        performance = {
          reset = false,
        },
      }) 
    '';
  };
}
