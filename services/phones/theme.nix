{ me }:
pkgs:

pkgs.runCommand "phone-theme" {
  THEME_FILE = ../../display/carbonfox.yaml;
  FONT_TTF = "${pkgs.nerd-fonts.hack}/share/fonts/truetype/NerdFonts/Hack/HackNerdFontMono-Regular.ttf";
  WIKI_URL = "https://wiki.${me.domains.home}";
} (builtins.readFile ./theme.sh)
