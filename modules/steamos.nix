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

      home.file = {
        ".steam/root/compatibilitytools.d/GE-Proton8-16".source = builtins.fetchTarball {
          url = "https://github.com/GloriousEggroll/proton-ge-custom/releases/download/GE-Proton8-16/GE-Proton8-16.tar.gz";
        };
      };

      home.sessionVariables = {
        STARDEW_VALLEY_MODS = "~/.steam/steam/steamapps/common/Stardew Valley/Mods";
      };

      programs.zsh.shellAliases = {
        to-game-mode = "exec qdbus org.kde.Shutdown /Shutdown org.kde.Shutdown.logout";
        tgm = "to-game-mode";
      };


      xdg.mime.enable = true;

      home.activation.refreshMenu =
        lib.hm.dag.entryAfter
          [ "writeBoundary" ]
          "/usr/bin/xdg-desktop-menu forceupdate";
    }
  );
}
