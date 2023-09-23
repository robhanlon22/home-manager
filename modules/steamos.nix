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

      programs.zsh.shellAliases = {
        to-game-mode = "exec qdbus org.kde.Shutdown /Shutdown org.kde.Shutdown.logout";
        tgm = "to-game-mode";
      };
    }
  );
}
