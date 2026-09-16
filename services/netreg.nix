{
  lib,
  pkgs,
  ...
}:

let
  language = "cs";
  device = "/dev/serial/by-id/usb-BMR_BMR_USB_2.0__-__RS_485_BMQ36R4J-if00-port0";

  installer = pkgs.fetchurl {
    name = "BMR_setupNETREG.exe";
    url = "https://www.bmr.cz/ke-stazeni/software/regulace-topeni.html?download=436:software-netreg-pro-starsi-regulacni-systemy-rt-rnet-ukoncena-verze";
    hash = "sha256-Z1k0V+52+rKgM2UQx8yiwgpE0zOSzsKhG8zpwDMqHjE=";
  };

  app =
    pkgs.runCommand "netreg-app"
      {
        nativeBuildInputs = with pkgs; [
          innoextract
          p7zip
          icoutils
        ];
      }
      ''
        innoextract -q -d . --language ${language} --include app --include tmp ${installer}
        7z x -y -ocdm tmp/CDM2123620_Setup.exe >/dev/null || true
        mkdir -p $out/share/icons/hicolor/32x32/apps
        mv app $out/app
        cp cdm/i386/ftd2xx.dll $out/app/
        wrestool -x -t14 -o netreg.ico $out/app/netreg.exe
        icotool -x -o $out/share/icons/hicolor/32x32/apps/netreg.png netreg.ico
      '';

  launcher = pkgs.writeShellApplication {
    name = "netreg";
    runtimeInputs = with pkgs; [
      coreutils
      wineWow64Packages.stable
    ];
    text = ''
      export WINEPREFIX="''${XDG_DATA_HOME:-$HOME/.local/share}/netreg"
      export LANG=cs_CZ.UTF-8
      export WINEDEBUG=-all
      export WINEDLLOVERRIDES="mscoree,mshtml,winemenubuilder.exe="
      dir="$WINEPREFIX/drive_c/NetReg"
      if [ ! -d "$dir" ]; then
        mkdir -p "$WINEPREFIX"
        wineboot -u
        cp -r ${app}/app "$dir"
        chmod -R u+w "$dir"
        printf '[Settings]\r\nAutoOnline=1\r\n\r\n[Communication]\r\nMethod=1\r\nPort=COM1\r\n' > "$dir/rtnetcfg.ini"
        wine reg add 'HKLM\Software\Wine\Ports' /v COM1 /t REG_SZ /d ${device} /f
        wineserver -k
      fi
      wine reg add 'HKLM\Software\Wine\Ports' /v COM1 /t REG_SZ /d ${device} /f
      cd "$dir"
      exec wine netreg.exe "$@"
    '';
  };
in
{
  environment.systemPackages = [
    launcher
    (pkgs.makeDesktopItem {
      name = "netreg";
      desktopName = "NetReg";
      comment = "BMR RT/RNet heating regulation";
      exec = lib.getExe launcher;
      icon = "netreg";
      categories = [ "Utility" ];
    })
    app
  ];
}
