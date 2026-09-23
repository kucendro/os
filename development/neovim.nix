{ pkgs, ... }:
{
  programs.neovim = {
    enable = true;
    withRuby = false;
    withPython3 = false;
    extraPackages = [ pkgs.nixd ];
    plugins = with pkgs.vimPlugins; [
      lazy-nvim
      LazyVim
      mini-icons
      d2-vim
      rustaceanvim
      markdown-preview-nvim
    ];
    initLua = "./neovim.lua";
  };
}
