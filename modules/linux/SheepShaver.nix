{ pkgs, ... }:

let
  thePname = "SheepShaver";
  theVersion = "2023-09-11";

  appimage = pkgs.fetchurl {
    url = "https://github.com/Korkman/macemu-appimage-builder/releases/download/${theVersion}/SheepShaver-x86_64.AppImage";
    sha256 = "EUrjT+vWXTip/pmCSm0fyG5bP7o2pEgUEkYTdWRm9OY=";
  };

  extracted = pkgs.appimageTools.extract {
    src = appimage;
    pname = thePname;
    version = theVersion;
  };
in
pkgs.stdenv.mkDerivation {
  pname = thePname;
  version = theVersion;

  buildInputs = [ pkgs.makeWrapper pkgs.copyDesktopItems ];

  patchPhase = "true";
  configurePhase = "true";
  buildPhase = "true";
  fixupPhase = "true";
  unpackPhase = "true";

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin

    cp ${appimage} $out/bin/${thePname}
    chmod +x $out/bin/${thePname}

    cp -r --no-preserve=mode ${extracted}/usr/share $out/share

    runHook postInstall;
  '';

  desktopItems = [
    (pkgs.makeDesktopItem {
      name = thePname;
      desktopName = "SheepShaver";
      comment = "Open source classic PowerPC Mac OS emulator";
      exec = thePname;
      icon = "SheepShaver";
      terminal = false;
      startupNotify = false;
      categories = [ "Emulator" "System" ];
      actions = {
        launch-skip-settings = {
          name = "Start SheepShaver (skip settings)";
          exec = "${thePname} --nogui true";
        };

        launch-force-settings = {
          name = "Start SheepShaver (force settings)";
          exec = "${thePname} --nogui false";
        };

        launch-opengl = {
          name = "Start SheepShaver (opengl)";
          exec = "${thePname} --sdlrender opengl";
        };
      };
    })
  ];
}
