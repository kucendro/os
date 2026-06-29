{
  lib,
  pkgs,
  me,
  ...
}:

let
  mkTermuxSetup =
    name: _address:
    let
      peer = import (../targets + "/${name}/peer.nix");
    in
    pkgs.writeShellApplication {
      name = "termux-setup-${name}";
      runtimeInputs = with pkgs; [
        sops
        coreutils
        gnused
        openssh
        gzip
        qrencode
      ];
      text = ''
        export PHONE_NAME=${name}
        export ME_NAME=${me.name}
        export DOMAIN=ts.kucendro.dev
        export REACHES=${lib.escapeShellArg (lib.concatStringsSep " " peer.reaches)}
        export TRUSTED_PUBKEY_NAMES=${lib.escapeShellArg (lib.concatStringsSep " " peer.trustedBy)}
        export SECRETS_FILE=${../secrets/secrets.yaml}
        export THEME_FILE=${../display/carbonfox.yaml}
        export FONT_URL=https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Hack/Regular/HackNerdFontMono-Regular.ttf
      ''
      + builtins.readFile ../scripts/termux-setup.sh;
    };

  termuxPhones = lib.filterAttrs (
    name: _: builtins.pathExists (../targets + "/${name}/peer.nix")
  ) me.phones;
in
{
  environment.systemPackages = lib.mapAttrsToList mkTermuxSetup termuxPhones;
}
