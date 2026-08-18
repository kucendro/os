{ pkgs, ... }:
{
  programs.neovim = {
    enable = true;
    withRuby = false;
    withPython3 = false;
    plugins = with pkgs.vimPlugins; [
      lazy-nvim
      LazyVim
      mini-icons
      d2-vim
      rustaceanvim
      markdown-preview-nvim
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
          { "nvim-mini/mini.nvim", lazy = false },
          { "nvim-mini/mini.icons",
             dir = "${pkgs.vimPlugins.mini-icons}",
             lazy = false,
          },
          {
            "iamcco/markdown-preview.nvim",
            dir = "${pkgs.vimPlugins.markdown-preview-nvim}",
            build = function() vim.fn["mkdp#util#install"]() end,
            cmd = { "MarkdownPreview", "MarkdownPreviewStop", "MarkdownPreviewToggle" },
            ft = { "markdown" },
            init = function()
              vim.g.mkdp_filetypes = { "markdown" }
            end,
          },
        },
        performance = {
          reset = false,
        },
      }) 
    '';
  };
}
