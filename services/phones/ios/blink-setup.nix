{
  lib,
  me,
  hosts,
}:
pkgs:

let
  peer = import ../peer.nix;

  orderedHosts =
    (builtins.filter (h: builtins.elem h hosts) peer.order) ++ (lib.subtractLists peer.order hosts);

  # Blink keeps keys in the Keychain, the one named id_ed25519 is used by default
  sshConfig = ''
    Host ${lib.concatStringsSep " " orderedHosts}
      User ${me.name}
  '';

  mkBlinkSetup =
    name: _phone:
    pkgs.writeShellApplication {
      name = "blink-setup-${name}";
      runtimeInputs = with pkgs; [
        coreutils
        qrencode
      ];
      text = ''
        export PHONE_NAME=${name}
        export SSH_CONFIG=${lib.escapeShellArg sshConfig}
        export REACHES=${lib.escapeShellArg (lib.concatStringsSep " " orderedHosts)}
        export DEFAULT_REMOTE=${peer.defaultRemote}
        export WIKI_URL=https://wiki.${me.domains.home}
      ''
      + builtins.readFile ./blink-setup.sh;
    };

  blinkPhones = lib.filterAttrs (_: phone: phone.os == "ios") me.phones;
in
lib.mapAttrs mkBlinkSetup blinkPhones
