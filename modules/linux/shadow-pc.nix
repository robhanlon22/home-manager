{ pkgs, ... }:

let
  appimage = pkgs.fetchurl {
    url = "https://update.shadow.tech/launcher/prod/linux/ubuntu_18.04/ShadowPC.AppImage";
    sha256 = "r4gDOV6O/PJVuQeN0zzmzbZF7Tp0D6UDInZg9LLjx7A=";
    name = "ShadowPC.AppImage";
  };
  extracted = pkgs.appimageTools.extract {
    src = appimage;
    pname = "shadow-pc";
    version = "prod";
  };
in
pkgs.stdenv.mkDerivation rec {
  pname = "shadow-pc";
  version = "prod";

  buildInputs = [ pkgs.makeWrapper pkgs.copyDesktopItems ];

  patchPhase = "true";
  configurePhase = "true";
  buildPhase = "true";
  fixupPhase = "true";
  unpackPhase = "true";

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin

    cp ${appimage} $out/bin/shadow-pc
    chmod +x $out/bin/shadow-pc
    wrapProgram $out/bin/shadow-pc --add-flags '--no-sandbox'

    cp -r --no-preserve=mode ${extracted}/usr/share $out/share

    runHook postInstall;
  '';

  desktopItems = [
    (pkgs.makeDesktopItem {
      name = "shadow-pc";
      desktopName = "Shadow PC";
      exec = "shadow-pc %U";
      terminal = false;
      icon = "shadow-launcher";
      startupWMClass = "Shadow PC";
      mimeTypes = [ "x-scheme-handler/tech.shadow" ];
      categories = [ "AudioVideo" "Audio" "Video" "Player" "TV" ];
    })
  ];
}
