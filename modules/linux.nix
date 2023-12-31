{ pkgs, lib, ... }:

let
  apps = import ./linux/apps.nix { inherit pkgs; };
in
{
  config = lib.mkIf pkgs.stdenv.hostPlatform.isLinux (
    {
      home.packages = [
        (pkgs.callPackage linux/ShadowPC.nix { })
        (pkgs.callPackage linux/SheepShaver.nix { })
        pkgs.wl-clipboard
        pkgs.wl-clipboard-x11
      ];

      targets.genericLinux.enable = true;

      programs.kitty.package = pkgs.callPackage ./linux/kitty.nix { };

      programs.bash.enable = true;

      programs.librewolf = {
        enable = true;
        package = apps.fixExecDir pkgs.librewolf pkgs.librewolf;
      };

      xdg.mime.enable = true;

      home.activation.refreshMenu =
        lib.hm.dag.entryAfter
          [ "writeBoundary" ]
          "/usr/bin/xdg-desktop-menu forceupdate";
    }
  );
}
