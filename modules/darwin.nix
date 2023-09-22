{ pkgs, lib, config, ... }:

{
  config = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
    programs.kitty.package =
      let
        app = "kitty.app";
      in
      pkgs.stdenv.mkDerivation rec {
        pname = "dmg-kitty";
        version = "0.30.0";

        src = pkgs.fetchurl {
          url = "https://github.com/kovidgoyal/kitty/releases/download/v${version}/kitty-0.30.0.dmg";
          sha256 = "VTYnynU5WlUz3J7uokqkPoa8UKK5zh0Yik0UTzx3bhQ=";
        };

        dontPatch = true;
        dontConfigure = true;
        dontBuild = true;
        dontFixup = true;

        # kitty.dmg is not HFS formatted, default unpackPhase fails
        # https://discourse.nixos.org/t/help-with-error-only-hfs-file-systems-are-supported-on-ventura
        unpackCmd = ''
          mnt="$(mktemp -d)"

          function finish {
            /usr/bin/hdiutil detach $mnt -force
          }

          trap finish EXIT

          /usr/bin/hdiutil attach -nobrowse -readonly $src -mountpoint $mnt

          shopt -s extglob

          dest="$PWD"

          (cd "$mnt"; /usr/bin/ditto "${app}" "$dest/${app}")
        '';

        sourceRoot = app;

        installPhase = ''
          runHook preInstall

          /usr/bin/ditto "../${app}" "$out/Applications/${app}"

          runHook postInstall
        '';
      };

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
            builtins.readFile lastAppsFile
          else
            "";
        appsPath = "${config.home.homeDirectory}/Applications/Nix";
      in
      lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        next_apps=$(readlink -f "${apps}/Applications/"* | sort)

        if [ "${lastApps}" = "$next_apps" ]; then
          exit
        fi

        echo "Apps have changed. Updating macOS aliases..."

        $DRY_RUN_CMD mkdir -p "${appsPath}"

        $DRY_RUN_CMD "${pkgs.fd}/bin/fd" \
          -t l -d 1 . "${apps}/Applications" \
          -x $DRY_RUN_CMD "${flakePkg "github:reckenrode/mkAlias"}/bin/mkalias" \
          -L {} "${appsPath}/{/}"

        [ -z "$DRY_RUN_CMD" ] && echo "$next_apps" > "${lastAppsFile}"
      '';
  };
}
