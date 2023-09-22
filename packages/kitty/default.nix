{ fetchurl, stdenv, pkgs }:

if stdenv.hostPlatform.isLinux then
  pkgs.kitty
else
  stdenv.mkDerivation rec {
    pname = "dmg-kitty";
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
    unpackCmd = builtins.readFile ./unpackCmd.sh;

    sourceRoot = "kitty.app";

    installPhase = builtins.readFile ./installPhase.sh;
  }
