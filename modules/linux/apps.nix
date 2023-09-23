{ pkgs }:

let
  xdgApps = "share/applications";
  appsDir = pkg: "${pkg}/${xdgApps}";
  readAppsDir = pkg: (builtins.attrNames (builtins.readDir (appsDir pkg)));

  modify =
    pkg: name: sedScript: app:
    pkgs.runCommand "${name}-app-${app}" { } ''
      set -eo pipefail
      xdgApps="$out/${xdgApps}"
      mkdir -p "$xdgApps"

      cat "${appsDir pkg}/${app}" | sed -r '${sedScript}' > "$xdgApps/${app}"
    '';

  modifyDir =
    pkg: name: sedScript:
    map (modify pkg name sedScript) (readAppsDir pkg);

  fixExec =
    binSrc: appSrc: name: app:
    modify
      appSrc
      name
      "s!Exec=([^ ]+ |.+$)!Exec=${binSrc}/bin/\\1 !g"
      app;

  fixExecDir =
    binSrc: appSrc:
    let
      name = "fixed-exec-${appSrc.name}";
      fixedApps = map (fixExec binSrc appSrc name) (readAppsDir appSrc);
    in
    pkgs.buildEnv {
      name = name;
      paths = [ binSrc ] ++ (map pkgs.hiPrio fixedApps);
    };
in
{ inherit modify modifyDir fixExec fixExecDir; }
