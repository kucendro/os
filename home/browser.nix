{ ... }:
let
  extensions = {
    ublock-origin-lite = "ddkjiahejlhfcafbddmgiahcphecmpfh";
    bitwarden = "nngceckbapebfimnlniiiahkandclblb";
    claude = "fcoeoabgfenejglbffodgkkbkcdhcgfn";
    duckduckgo = "bkdgflcldnnnapblkhphbgpggdiikppg";
    karakeep = "kgcjekpmcjjogibpjebkhaanilehneje";
    vimium = "dbepggeogbaibhgnhhndojpepiihcmeb";
    zotero = "ekhagklcjbdpajgpjgmbionohlpdbjgc";
  };
in
{
  programs.chromium = {
    enable = true;
    commandLineArgs = [
      "--hide-crash-restore-bubble"
      "--restore-last-session"
    ];
    extensions = builtins.attrValues extensions;
  };
}
