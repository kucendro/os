{ pkgs, ... }:
let
  plugins = with pkgs.vimPlugins; [
    lazy-nvim
    LazyVim
    mini-icons
    d2-vim
    rustaceanvim
    markdown-preview-nvim
  ];
  lazyPath = pkgs.linkFarm "lazy-plugins" (
    map (p: {
      name = p.pname;
      path = p;
    }) plugins
  );
in
{
  programs.neovim = {
    enable = true;
    withRuby = false;
    withPython3 = false;
    extraPackages = [ pkgs.nixd ];
    inherit plugins;
    initLua = ''
      vim.g.nix_lazy_path = "${lazyPath}"
    ''
    + builtins.readFile ./neovim.lua;
  };
}
