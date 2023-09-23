{ pkgs, lib, ... }:

{
  config = lib.mkIf pkgs.stdenv.hostPlatform.isLinux (
    let
      nixGL = import <nixgl> { };
      nixGLWrap = pkg:
        let
          bin = "${pkg}/bin";
        in
        pkgs.buildEnv {
          name = "nixGL-${pkg.name}";
          paths = map
            (name: pkgs.writeShellScriptBin name ''
              exec -a "$0" ${nixGL.auto.nixGLDefault}/bin/nixGL ${bin}/${name} "$@"
            '')
            (builtins.attrNames (builtins.readDir bin));
        };

      nixGLKitty = nixGLWrap pkgs.kitty;
      appsDir = "share/applications";
      kittyAppsDir = "${pkgs.kitty}/${appsDir}";
      fixedKittyApps = map
        (name: pkgs.runCommand "fixed-${name}" { } ''
          set -eo pipefail
          appsDir="$out/${appsDir}"
          mkdir -p "$appsDir"
          cat "${kittyAppsDir}/${name}" |\
            sed "s|Icon=kitty|Icon=${pkgs.kitty}/share/icons/hicolor/256x256/apps/kitty.png|g" |\
            sed "s|Exec=kitty|Exec=${nixGLKitty}/bin/kitty|g" > "$appsDir/${name}"
        '')
        (builtins.attrNames (builtins.readDir kittyAppsDir));
      kittyPkg =
        pkgs.buildEnv {
          name = "final-kitty";
          paths = [ nixGLKitty ] ++ fixedKittyApps;
        };
    in
    {
      home.packages = [
        pkgs.wl-clipboard
        pkgs.wl-clipboard-x11
        pkgs.gcc
      ];

      targets.genericLinux.enable = true;

      programs.kitty.package = kittyPkg;

      programs.bash.enable = true;

      programs.librewolf.enable = true;

      xdg.mime.enable = true;
    }
  );
}
