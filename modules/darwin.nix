{ pkgs, lib, config, ... }:

{
  config = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
    programs.kitty.package =
      let
        app = "kitty.app";
        appPath = "$out/Applications/${app}";
        contents = "${appPath}/Contents";
        macOS = "${contents}/MacOS";
        resources = "${contents}/Resources";
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

        nativeBuildInputs = [ pkgs.installShellFiles ];

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

        outputs = [ "out" "terminfo" "shell_integration" "kitten" ];

        sourceRoot = app;

        installPhase = ''
          runHook preInstall

          /usr/bin/ditto "../${app}" "${appPath}"

          mkdir -p "$out/bin" "$kitten/bin"

          ln -s "${macOS}/kitty" "$out/bin/kitty"
          ln -s "${macOS}/kitten" "$out/bin/kitten"
          cp "${macOS}/kitten" "$kitten/bin/kitten"

          installManPage "${resources}/man/man1/kitty.1"

          installShellCompletion --cmd kitty \
            --bash <("$out/bin/kitty" +complete setup bash) \
            --fish <("$out/bin/kitty" +complete setup fish2) \
            --zsh  <("$out/bin/kitty" +complete setup zsh)

          mkdir -p $terminfo/share
          mv "${resources}/terminfo" $terminfo/share/terminfo

          mkdir -p $out/nix-support
          echo "$terminfo" >> "$out/nix-support/propagated-user-env-packages"

          cp -r "${resources}/kitty/shell-integration" "$shell_integration"

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
