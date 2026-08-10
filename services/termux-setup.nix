{ lib, me }:
pkgs:

let
  peer = import ../targets/mobile/peer.nix;

  mkTermuxSetup =
    name: _phone:
    pkgs.writeShellApplication {
      name = "termux-setup-${name}";
      runtimeInputs = with pkgs; [
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
        export DEFAULT_REMOTE=${peer.defaultRemote}
        export THEME_FILE=${../display/carbonfox.yaml}
        export FONT_URL=https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Hack/Regular/HackNerdFontMono-Regular.ttf
      ''
      + builtins.readFile ../scripts/termux-setup.sh;
    };

  termuxPhones = lib.filterAttrs (name: phone: phone.os == "android") me.phones;
in
lib.mapAttrs mkTermuxSetup termuxPhones
