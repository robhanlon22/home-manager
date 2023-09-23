{ pkgs, lib, ... }:

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

      programs.librewolf.enable = true;

      xdg.mime.enable = true;
    }
  );
}
