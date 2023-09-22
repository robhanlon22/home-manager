{ config, pkgs, lib, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "rob";
  home.homeDirectory = "/Users/rob";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    (pkgs.nerdfonts.override { fonts = [ "CascadiaCode" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
    pkgs.fd
    pkgs.nil
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
    ".oh-my-zsh/custom/themes/powerlevel10k".source = pkgs.fetchFromGitHub {
      owner = "romkatv";
      repo = "powerlevel10k";
      rev = "refs/tags/v1.19.0";
      sha256 = "+hzjSbbrXr0w1rGHm6m2oZ6pfmD6UUDBfPd7uMg5l5c=";
    };

    ".p10k.zsh".source = etc/zsh/p10k.zsh;
  };

  # You can also manage environment variables but you will have to manually
  # source
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/rob/etc/profile.d/hm-session-vars.sh
  #
  # if you don't want to manage your shell through Home Manager.
  home.sessionVariables = {
    ZSH_CUSTOM = ".oh-my-zsh/custom";
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    withRuby = true;
    withPython3 = true;
    withNodeJs = true;
    plugins = with pkgs.vimPlugins; [
      dracula-nvim
      fzf-vim
      fzfWrapper
      vim-commentary
      vim-gitgutter
      zoxide-vim
    ];
    extraLuaConfig = builtins.readFile etc/nvim/init.lua;
  };

  programs.ripgrep = {
    enable = true;
    arguments = ["--glob=!Dropbox/**/*"];
  };

  programs.zsh = {
    enable = true;
    initExtra = builtins.readFile etc/zsh/zshrc;
    shellAliases = {
      ls = "ls --color";
    };
    oh-my-zsh = {
      enable = true;
      plugins = ["git" "ruby" "rust" "python"];
      theme = "powerlevel10k/powerlevel10k";
    };
  };

  programs.zoxide.enable = true;
  programs.rbenv.enable = true;
  programs.kitty = {
    enable = true;
    package = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin (pkgs.callPackage ./kitty.nix {});
    shellIntegration.enableZshIntegration = true;
    theme = "Dracula";
    font = {
      name = "CaskaydiaCove Nerd Font Mono";
      size = 14.0;
    };
  };

  programs.fzf = {
    enable = true;
    defaultCommand = "fd --type file --hidden --no-ignore";
  };

  home.activation.aliasApplications = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin (
    let
      flakePkg = uri:
        (builtins.getFlake uri).packages.${builtins.currentSystem}.default;
      apps = pkgs.buildEnv {
        name = "home-manager-applications";
        paths = config.home.packages;
        pathsToLink = "/Applications";
      };
      lastAppsFile = "${config.xdg.stateHome}/nix/linked-apps.txt";
    in
      lib.hm.dag.entryAfter ["writeBoundary"] ''
        last_apps=$(cat "${lastAppsFile}" 2>/dev/null || echo "")
        next_apps=$(readlink -f ${apps}/Applications/* | sort)

        if [ "$last_apps" != "$next_apps" ]; then
          echo "Apps have changed. Updating macOS aliases..."

          apps_path="$HOME/Applications/Nix"
          $DRY_RUN_CMD mkdir -p "$apps_path"

          $DRY_RUN_CMD ${pkgs.fd}/bin/fd \
            -t l -d 1 . ${apps}/Applications \
            -x $DRY_RUN_CMD "${flakePkg "github:reckenrode/mkAlias"}/bin/mkalias" \
            -L {} "$apps_path/{/}"

          [ -z "$DRY_RUN_CMD" ] && echo "$next_apps" > "${lastAppsFile}"
        fi
      ''
  );

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
