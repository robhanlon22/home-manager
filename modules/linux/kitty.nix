{ pkgs }:

let
  nixGL = import ./nixGL.nix { inherit pkgs; };
  nixGLKitty = nixGL pkgs.kitty;
  xdgApps = "share/applications";
  kittyApps = "${pkgs.kitty}/${xdgApps}";
  fixedKittyApps = map
    (name: pkgs.runCommand "fixed-${name}" { } ''
      set -eo pipefail
      xdgApps="$out/${xdgApps}"
      mkdir -p "$xdgApps"

      cat "${kittyApps}/${name}" |\
        sed "s|Icon=kitty|Icon=${pkgs.kitty}/share/icons/hicolor/256x256/apps/kitty.png|g" |\
        sed "s|Exec=kitty|Exec=${nixGLKitty}/bin/kitty|g" > "$xdgApps/${name}"
    '')
    (builtins.attrNames (builtins.readDir kittyApps));
in
pkgs.buildEnv {
  name = "fixed-kitty";
  paths = [ nixGLKitty ] ++ fixedKittyApps;
}
