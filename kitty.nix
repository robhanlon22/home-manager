{ lib
, fetchurl
, stdenv
, undmg
}:

stdenv.mkDerivation rec {
  pname = "kitty";
  version = "0.30.0";
  src = fetchurl {
    url = "https://github.com/kovidgoyal/kitty/releases/download/v${version}/kitty-0.30.0.dmg";
    sha256 = "VTYnynU5WlUz3J7uokqkPoa8UKK5zh0Yik0UTzx3bhQ=";
  };

  dontPatch = true;
  dontConfigure = true;
  dontBuild = true;
  dontFixup = true;

  # kitty.dmg is not HFS formatted, default unpackPhase fails
  # https://discourse.nixos.org/t/help-with-error-only-hfs-file-systems-are-supported-on-ventura
  unpackCmd = ''
    mnt=$(mktemp -d)

    /usr/bin/hdiutil attach -nobrowse -readonly $src -mountpoint $mnt

    shopt -s extglob
    DEST="$PWD"
    (cd "$mnt"; cp -a !(Applications) "$DEST/")
  '';

  sourceRoot = "kitty.app";

  installPhase = ''
    runHook preInstall

    app="$out/Applications/kitty.app"
    macOS="$app/Contents/macOS"
    bin="$out/bin"
    shim="$bin/kitty"

    mkdir -p "$app" "$bin"
    cp -R . "$app"

    ln -s "$macOS"/kitten "$bin"

    cat > "$shim" <<-EOF
      #!/bin/sh
      open -a "$app" --args -1 "\$@"
    EOF

    chmod +x "$shim"

    runHook postInstall
  '';
}
