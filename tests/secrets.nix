{
  pkgs,
  lib,
  secrets,
}:

let
  formats = lib.unique (map (secret: secret.format) (lib.attrValues secrets));

  pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ2emJ0xYTyw8Su01xsxl/lPvRqqvHvCFQMAxeak5com vm";

  value = name: if lib.hasSuffix "pubkey" name then pubkey else "vm";

  plain =
    format:
    pkgs.writeText "vm-${format}.json" (
      builtins.toJSON (
        lib.mapAttrs' (name: secret: lib.nameValuePair secret.key (value name)) (
          lib.filterAttrs (_: secret: secret.format == format) secrets
        )
      )
    );
in
pkgs.runCommand "vm-secrets"
  {
    nativeBuildInputs = [
      pkgs.age
      pkgs.sops
    ];
  }
  ''
    mkdir $out
    age-keygen -o $out/key.txt
    recipient=$(age-keygen -y $out/key.txt)
    ${lib.concatMapStrings (format: ''
      sops encrypt --age $recipient --input-type json --output-type ${format} ${plain format} > $out/${format}
    '') formats}
  ''
