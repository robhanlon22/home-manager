{ pkgs }:

pkg: name: sedScript:

let
  xdgApps = "share/applications";
  pkgApps = "${pkg}/${xdgApps}";
in
map
  (app:
  (
    pkgs.runCommand "${name}-app-${app}" { } ''
      set -eo pipefail
      xdgApps="$out/${xdgApps}"
      mkdir -p "$xdgApps"

      cat "${pkgApps}/${app}" | sed -r '${sedScript}' > "$xdgApps/${app}"
    ''
  )
  )
  (builtins.attrNames (builtins.readDir pkgApps))
