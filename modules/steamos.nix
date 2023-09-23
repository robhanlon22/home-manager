{ pkgs, lib, ... }:

let
  isSteamOS =
    pkgs.stdenv.hostPlatform.isLinux &&
    builtins.pathExists "/etc/steamos-release";
in
{
  config = lib.mkIf isSteamOS (
    let
      bins = ../bin/steamos;
    in
    {
      home.packages =
        map
          (bin:
            pkgs.writeScriptBin "${bin}" (builtins.readFile "${bins}/${bin}")
          )
          (builtins.attrNames (builtins.readDir bins));
    }
  );
}
