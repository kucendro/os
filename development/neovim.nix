{ pkgs, ... }:
let
  catppuccin = pkgs.vimPlugins.catppuccin-nvim;
in
{
  programs.neovim = {
    enable = true;
    plugins = with pkgs.vimPlugins; [
      lazy-nvim
      LazyVim
      catppuccin-nvim
    ];
    initLua = ''
      require("lazy").setup({
        spec = {
          { "LazyVim/LazyVim", import = "lazyvim.plugins" },
          {
            "catppuccin/nvim",
            name = "catppuccin",
            dir = "${catppuccin}",
            lazy = false,
            priority = 1000,
            opts = { flavour = "macchiato" },
          },
        },
        performance = {
          reset = false,  -- don't clear the Nix-managed runtimepath
        },
      })

      vim.cmd.colorscheme("catppuccin")
    '';
  };
}
