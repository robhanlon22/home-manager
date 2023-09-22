{ pkgs, lib, ... }:

let
  isSteamOS =
    pkgs.stdenv.hostPlatform.isLinux &&
    builtins.pathExists "/etc/steamos-release";
in
{
  config = lib.mkIf isSteamOS {
    home.packages = [
      (pkgs.writeScriptBin "desktop.sh" (builtins.readFile ../bin/steamos/desktop.sh))
      (pkgs.writeScriptBin "shadow.sh" (builtins.readFile ../bin/steamos/shadow.sh))
    ];
  };
}
