{ pkgs }:

let
  nixGL = import ./nixGL.nix { inherit pkgs; };
  apps = import ./apps.nix { inherit pkgs; };

  fixedKittyIcons = apps.modifyDir
    pkgs.kitty
    "fixed-icons-${pkgs.kitty.name}"
    "s|Icon=kitty|Icon=${pkgs.kitty}/share/icons/hicolor/256x256/apps/kitty.png|g";
in
apps.fixExecDir
  (nixGL pkgs.kitty)
  (pkgs.buildEnv {
    name = "fixed-icons-${pkgs.kitty.name}";
    paths = fixedKittyIcons;
  })
