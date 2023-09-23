{ pkgs }:

let
  nixGL = import ./nixGL.nix { inherit pkgs; };
  nixGLKitty = nixGL pkgs.kitty;

  xdgApps = "share/applications";
  kittyApps = "${pkgs.kitty}/${xdgApps}";

  fixedKittyApps = map
    (desktop: pkgs.runCommand "fixed-${pkgs.kitty.name}-desktop-${desktop}" { } ''
      set -eo pipefail
      xdgApps="$out/${xdgApps}"
      mkdir -p "$xdgApps"

      cat "${kittyApps}/${desktop}" |\
        sed "s|Icon=kitty|Icon=${pkgs.kitty}/share/icons/hicolor/256x256/apps/kitty.png|g" |\
        sed "s|Exec=kitty|Exec=${nixGLKitty}/bin/kitty|g" > "$xdgApps/${desktop}"
    '')
    (builtins.attrNames (builtins.readDir kittyApps));
in
pkgs.buildEnv {
  name = "fixed-${pkgs.kitty.name}";
  paths = [ nixGLKitty ] ++ fixedKittyApps;
}
