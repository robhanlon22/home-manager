{ pkgs, lib, ... }:

{
  config = lib.mkIf pkgs.stdenv.hostPlatform.isLinux (
    let
      nixGL = import <nixgl> { };
      nixGLWrap = pkg:
        let
          bin = "${pkg}/bin";
          executables = builtins.attrNames (builtins.readDir bin);
        in
        pkgs.buildEnv {
          name = "nixGL-${pkg.name}";
          paths = map
            (name: pkgs.writeShellScriptBin name ''
              exec -a "$0" ${nixGL.auto.nixGLDefault}/bin/nixGL ${bin}/${name} "$@"
            '')
            executables;
        };
      kittyPkg =
        let
          wrapped = nixGLWrap pkgs.kitty;
          fixedApps = pkgs.runCommand "fixed-kitty" { } ''
            set -eo pipefail

            mkdir -p "$out/share/applications"

            shopt -s nullglob
            for file in "${pkgs.kitty}"/share/applications/*; do
              app="$out/share/applications/$(basename "$file")"
              cp "$file" "$app"
              sed -i "s|Icon=kitty|Icon=${pkgs.kitty}/share/icons/hicolor/256x256/apps/kitty.png|g" "$app"
              sed -i "s|Exec=kitty|Exec=${wrapped}/bin/kitty|g" "$app"
            done
            shopt -u nullglob
          '';
        in
        pkgs.buildEnv {
          name = "final-kitty";
          paths = [ wrapped fixedApps ];
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

      xdg.mime.enable = true;
    }
  );
}
