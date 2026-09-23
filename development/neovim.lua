require("lazy").setup({
  spec = {
    { "LazyVim/LazyVim",     import = "lazyvim.plugins" },
    {
      "terrastruct/d2-vim",
      ft = { "d2" },
    },
    {
      "neovim/nvim-lspconfig",
      opts = {
        servers = {
          rust_analyzer = {
            mason = false,
          },
          nil_ls = { enabled = false },
          nixd = {
            mason = false,
            settings = {
              nixd = {
                nixpkgs = { expr = 'import (builtins.getFlake (toString ./.)).inputs.nixpkgs { }' },
                options = {
                  nixos = { expr = '(builtins.getFlake (toString ./.)).nixosConfigurations.nixbook.options' },
                  ["home-manager"] = { expr = '(builtins.getFlake (toString ./.)).nixosConfigurations.nixbook.options.home-manager.users.type.getSubOptions []' },
                },
              },
            },
          },
        },
      },
    },
    { "nvim-mini/mini.nvim", lazy = false },
    {
      "nvim-mini/mini.icons",
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
