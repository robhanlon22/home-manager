{ pkgs, lib, ... }:

{
  config = lib.mkIf pkgs.stdenv.hostPlatform.isLinux (
    let
      nixGL = import <nixgl> { };
      nixGLWrap = pkg:
        pkg.overrideAttrs (old: {
          name = "nixGL-${pkg.name}";
          buildCommand = ''
            set -eo pipefail

            ${
            # Heavily inspired by https://stackoverflow.com/a/68523368/6259505
            pkgs.lib.concatStringsSep "\n" (map (outputName: ''
              echo "Copying output ${outputName}"
              set -x
              cp -rs --no-preserve=mode "${pkg.${outputName}}" "''$${outputName}"
              set +x
            '') (old.outputs or [ "out" ]))}

            rm -rf $out/bin/*
            shopt -s nullglob # Prevent loop from running if no files
            for file in ${pkg.out}/bin/*; do
              echo "#!${pkgs.bash}/bin/bash" > "$out/bin/$(basename $file)"
              echo "exec -a \"\$0\" ${nixGL.auto.nixGLDefault}/bin/nixGL $file \"\$@\"" >> "$out/bin/$(basename $file)"
              chmod +x "$out/bin/$(basename $file)"
            done
            shopt -u nullglob # Revert nullglob back to its normal default state
          '';
        });
    in
    {
      home.packages = [
        pkgs.wl-clipboard
        pkgs.wl-clipboard-x11
        pkgs.gcc
        (pkgs.writeScriptBin "desktop.sh" (builtins.readFile ../bin/desktop.sh))
        (pkgs.writeScriptBin "shadow.sh" (builtins.readFile ../bin/shadow.sh))
      ];

      targets.genericLinux.enable = true;

      programs.kitty.package = nixGLWrap pkgs.kitty;
    }
  );
}
