{ pkgs }:

binSrc: appSrc:

let
  xdgApps = "share/applications";
  pkgApps = "${appSrc}/${xdgApps}";
  name = "fixed-apps-${appSrc.name}";
  fixedApps = map
    (app:
      pkgs.hiPrio (
        pkgs.runCommand "${name}-app-${app}" { } ''
          set -eo pipefail
          xdgApps="$out/${xdgApps}"
          mkdir -p "$xdgApps"

          cat "${pkgApps}/${app}" |\
            sed -r 's!Exec=([^ ]+ |.+$)!Exec=${binSrc}/bin/\1 !g' > "$xdgApps/${app}"
        ''
      )
    )
    (builtins.attrNames (builtins.readDir pkgApps));
in
pkgs.buildEnv {
  name = name;
  paths = [ binSrc ] ++ fixedApps;
}
