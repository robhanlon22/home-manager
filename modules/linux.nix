{ pkgs, lib, ... }:

let
  fixApps = import ./linux/fixApps.nix { inherit pkgs; };
in
{
  config = lib.mkIf pkgs.stdenv.hostPlatform.isLinux (
    {
      home.packages = [
        pkgs.wl-clipboard
        pkgs.wl-clipboard-x11
        pkgs.gcc
      ];

      targets.genericLinux.enable = true;

      programs.kitty.package = pkgs.callPackage ./linux/kitty.nix { };

      programs.bash.enable = true;

      programs.librewolf = {
        enable = true;
        package = fixApps pkgs.librewolf pkgs.librewolf;
      };

      xdg.mime.enable = true;

      home.activation.refreshMenu =
        lib.hm.dag.entryAfter
          [ "writeBoundary" ]
          "/usr/bin/xdg-desktop-menu forceupdate";
    }
  );
}
