{ pkgs }:

binSrc: appSrc:

let
  modifyApps = import ./modifyApps.nix { inherit pkgs; };
  name = "fixed-apps-${appSrc.name}";
  fixedApps = modifyApps
    appSrc
    name
    "s!Exec=([^ ]+ |.+$)!Exec=${binSrc}/bin/\\1 !g";
in
pkgs.buildEnv {
  name = name;
  paths = [ binSrc ] ++ (map pkgs.hiPrio fixedApps);
}
