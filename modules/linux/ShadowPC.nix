{ pkgs, ... }:

let
  thePname = "ShadowPC";
  theVersion = "prod";
  appimage = pkgs.fetchurl {
    url = "https://update.shadow.tech/launcher/${theVersion}/linux/ubuntu_18.04/${thePname}.AppImage";
    sha256 = "r4gDOV6O/PJVuQeN0zzmzbZF7Tp0D6UDInZg9LLjx7A=";
    name = "ShadowPC.AppImage";
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
    wrapProgram $out/bin/${thePname} --add-flags '--no-sandbox'

    cp -r --no-preserve=mode ${extracted}/usr/share $out/share

    runHook postInstall;
  '';

  desktopItems = [
    (pkgs.makeDesktopItem {
      name = thePname;
      desktopName = "Shadow PC";
      exec = "${thePname} %U";
      terminal = false;
      icon = "shadow-launcher";
      startupWMClass = "Shadow PC";
      mimeTypes = [ "x-scheme-handler/tech.shadow" ];
      categories = [ "AudioVideo" "Audio" "Video" "Player" "TV" ];
    })
  ];
}
