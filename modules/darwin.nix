{ pkgs, lib, config, ... }:

{
  config = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
    programs.kitty.package = pkgs.callPackage ./darwin/kitty.nix { };

    home.packages = [ pkgs.coreutils-full ];

    home.activation.aliasApplications =
      let
        flakePkg = uri:
          (builtins.getFlake uri).packages.${builtins.currentSystem}.default;
        apps = pkgs.buildEnv {
          name = "home-manager-applications";
          paths = config.home.packages;
          pathsToLink = "/Applications";
        };
        lastAppsFile = "${config.xdg.stateHome}/nix/linked-apps.txt";
        lastApps =
          if builtins.pathExists lastAppsFile then
            lib.strings.fileContents lastAppsFile
          else
            "";
        appsPath = "${config.home.homeDirectory}/Applications/Nix";
      in
      lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        next_apps=$(readlink -f '${apps}/Applications/'* | sort)

        if [ '${lastApps}' != "$next_apps" ]; then
          echo "Apps have changed. Updating macOS aliases..."

          $DRY_RUN_CMD mkdir -p '${appsPath}'

          $DRY_RUN_CMD "${pkgs.fd}/bin/fd" \
            -t l -d 1 . '${apps}/Applications' \
            -x $DRY_RUN_CMD '${flakePkg "github:reckenrode/mkAlias"}/bin/mkalias' \
            -L {} '${appsPath}'/{/}

          [ -z "$DRY_RUN_CMD" ] && echo "$next_apps" > '${lastAppsFile}'
        fi
      '';
  };
}
