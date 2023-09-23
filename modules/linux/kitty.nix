{ pkgs }:

let
  nixGL = import ./nixGL.nix { inherit pkgs; };
  modifyApps = import ./modifyApps.nix { inherit pkgs; };
  fixApps = import ./fixApps.nix { inherit pkgs; };

  fixedKittyIcons = modifyApps
    pkgs.kitty
    "fixed-icons-${pkgs.kitty.name}"
    "s|Icon=kitty|Icon=${pkgs.kitty}/share/icons/hicolor/256x256/apps/kitty.png|g";
in
fixApps
  (nixGL pkgs.kitty)
  (pkgs.buildEnv {
    name = "fixed-icons-${pkgs.kitty.name}";
    paths = fixedKittyIcons;
  })
