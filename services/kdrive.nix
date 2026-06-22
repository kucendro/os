{ pkgs, ... }:

let
  pname = "kdrive";
  version = "3.8.5.2";

  src = pkgs.fetchurl {
    url = "https://download.storage.infomaniak.com/drive/desktopclient/kDrive-${version}-amd64.AppImage";
    hash = "sha256-8ec7d+HI89GSCKR8evgBtVy2qEzdrzPl97tPvvRzZAI=";
  };

  appdir = pkgs.runCommandLocal "${pname}-${version}-appdir" { } ''
    mkdir -p $out
    cp -a ${pkgs.appimageTools.extractType2 { inherit pname version src; }}/. $out/
    chmod -R u+w $out
    ln -sf usr/bin/sync-exclude.lst $out/sync-exclude.lst
  '';

  kdrive = pkgs.appimageTools.wrapAppImage {
    inherit pname version;
    src = appdir;

    extraInstallCommands = ''
      install -Dm444 ${appdir}/usr/share/applications/kDrive_client.desktop \
        $out/share/applications/kdrive.desktop
      substituteInPlace $out/share/applications/kdrive.desktop \
        --replace-fail 'Exec=kDrive' 'Exec=env QT_QPA_PLATFORM=xcb kdrive'
      cp -r ${appdir}/usr/share/icons $out/share/icons
    '';

    meta = {
      description = "Infomaniak kDrive desktop synchronization client (AppImage)";
      homepage = "https://www.infomaniak.com/en/apps/download-kdrive";
      platforms = [ "x86_64-linux" ];
    };
  };
in
{
  environment.systemPackages = [ kdrive ];
}
