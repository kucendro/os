{ pkgs, lib }:

let
  apps = {
    photocraft = {
      version = "0.8.2";
      hash = "sha256-FsMImXbu4tKQ2+c5httINcHsWgQ8XBawF7JISP9eqCc=";
    };
    lightcraft = {
      version = "0.7.1";
      hash = "sha256-hCiB9a0WUC3xHu70wo5dzyxdZrfU2DivcXmj/S4MtsA=";
    };
    filmcraft = {
      version = "0.7.2";
      hash = "sha256-QXHEv19X/SlHVlX4pt9HGf7ajI8+2VskddjcESrTvoY=";
    };
    designcraft = {
      version = "0.7.1";
      hash = "sha256-BaKyUx9vJnRrSnQwgf0A+ep3gi+heGY4AqDq7O1sFDc=";
    };
    vectorcraft = {
      version = "0.10.0";
      hash = "sha256-pVc1oZKHcDjJtMMGlQT3pzoFQzpI7d3Y6U/H0plapvw=";
    };
    pdfcraft = {
      version = "0.7.1";
      hash = "sha256-vH1lFREnNyD2pcy+DdWyxN3MtsV2oK/2GfOdLFZnoxU=";
    };
    effectcraft = {
      version = "0.9.2";
      hash = "sha256-kW0119wP1WULV/V25lViVtBd7fk+g6l0DBiSMZu0rBw=";
    };
    wordcraft = {
      version = "0.6.1";
      hash = "sha256-eb1UyBJ29upVEiJDKt7BXg6qtMtYgd7O446v16XKOPk=";
    };
    deckcraft = {
      version = "0.6.1";
      hash = "sha256-EhXmTxGqaFKb4+/iB49Rw5p2ad4dY8zhtVisEZPxdWk=";
    };
    gridcraft = {
      version = "0.6.1";
      hash = "sha256-YRY7Ytn6+BS4ZOGyVdFdwxCnGnLKA9h5H6gCRCAWJ0U=";
    };
    cadcraft = {
      version = "0.6.2";
      hash = "sha256-Sj7HxTUOchK9tPc1r2xs8xnuF3wRUp7FR8d8kmQq1J0=";
    };
    soundcraft = {
      version = "0.6.1";
      hash = "sha256-87+jc1FG5NexLNg2O4/ne77/Me6VOSKVAz9QsZFu/O4=";
    };
  };

  runtimeLibs = map lib.getLib (
    with pkgs;
    [
      libGL
      vulkan-loader
      wayland
      libxkbcommon
      libx11
      libxcursor
      libxi
      libxcb
      dbus
      libva
    ]
  );

  mkApp =
    pname:
    { version, hash }:
    pkgs.stdenv.mkDerivation {
      inherit pname version;

      src = pkgs.fetchurl {
        url = "https://github.com/storytold/${pname}/releases/download/v${version}/${pname}-${version}-linux-x86_64.tar.gz";
        inherit hash;
      };

      nativeBuildInputs = [ pkgs.autoPatchelfHook ];

      buildInputs = [
        pkgs.stdenv.cc.cc.lib
        pkgs.alsa-lib
      ];

      runtimeDependencies = runtimeLibs;

      appendRunpaths = [ "${pkgs.addDriverRunpath.driverLink}/lib" ];

      installPhase = ''
        runHook preInstall
        mkdir -p $out
        cp -r bin share $out/
        runHook postInstall
      '';

      meta = {
        homepage = "https://github.com/storytold/${pname}";
        license = with lib.licenses; [
          mit
          asl20
        ];
        sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
        platforms = [ "x86_64-linux" ];
        mainProgram = pname;
      };
    };
in
lib.mapAttrs mkApp apps
