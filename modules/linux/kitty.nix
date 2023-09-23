{ pkgs }:

let
  nixGL = import ./nixGL.nix { inherit pkgs; };
  nixGLKitty = nixGL pkgs.kitty;

  fixApps = import ./fixApps.nix { inherit pkgs; };

  xdgApps = "share/applications";
  kittyApps = "${pkgs.kitty}/${xdgApps}";

  fixedKittyIcons = map
    (app:
      (pkgs.runCommand "fixed-icons-${pkgs.kitty.name}-app-${app}" { } ''
        set -eo pipefail
        xdgApps="$out/${xdgApps}"
        mkdir -p "$xdgApps"

        cat "${kittyApps}/${app}" |\
          sed "s|Icon=kitty|Icon=${pkgs.kitty}/share/icons/hicolor/256x256/apps/kitty.png|g" > "$xdgApps/${app}"
      ''))
    (builtins.attrNames (builtins.readDir kittyApps));
in
fixApps
  nixGLKitty
  (
    pkgs.buildEnv {
      name = "fixed-icons-${pkgs.kitty.name}";
      paths = fixedKittyIcons;
    })
