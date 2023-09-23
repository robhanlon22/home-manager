{ pkgs, ... }:

let
  zshCustom = ".oh-my-zsh/custom";
in
{
  imports = [ ./modules/darwin.nix ./modules/linux.nix ./modules/steamos.nix ];

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = builtins.getEnv "USER";
  home.homeDirectory = builtins.getEnv "HOME";

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
    (pkgs.nerdfonts.override { fonts = [ "CascadiaCode" ]; })

    pkgs.curlFull
    pkgs.fd
    pkgs.go
    pkgs.jq
    pkgs.magic-wormhole
    pkgs.pre-commit
    pkgs.python3Full
    pkgs.rustc

    # LSP
    pkgs.lua-language-server
    pkgs.nil
  ];

  home.file = {
    "${zshCustom}/themes/powerlevel10k".source = pkgs.fetchFromGitHub {
      owner = "romkatv";
      repo = "powerlevel10k";
      rev = "refs/tags/v1.19.0";
      sha256 = "+hzjSbbrXr0w1rGHm6m2oZ6pfmD6UUDBfPd7uMg5l5c=";
    };

    ".p10k.zsh".source = etc/zsh/p10k.zsh;
  };

  home.sessionVariables = {
    ZSH_CUSTOM = "$HOME/${zshCustom}";
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
      nvim-lspconfig
      vim-commentary
      vim-gitgutter
      zoxide-vim
    ];
    extraLuaConfig = builtins.readFile etc/nvim/init.lua;
  };

  programs.ripgrep = {
    enable = true;
    arguments = [ "--glob=!Dropbox/**/*" ];
  };

  programs.zsh = {
    enable = true;
    initExtra = builtins.readFile etc/zsh/zshrc;
    shellAliases = {
      ls = "ls --color";
      hm = "home-manager";
      hms = "home-manager switch";
      hmb = "home-manager build";
    };
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "ruby" "rust" "python" ];
      theme = "powerlevel10k/powerlevel10k";
    };
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.rbenv = {
    enable = true;
    plugins = [
      {
        name = "ruby-build";
        src = pkgs.fetchFromGitHub {
          owner = "rbenv";
          repo = "ruby-build";
          rev = "v20230919";
          hash = "sha256-w9RwOqCFn9845MR01KwOz/FELiEYUcftBPbGs3Z/jTc=";
        };
      }
    ];
  };

  programs.kitty = {
    enable = true;
    shellIntegration.enableZshIntegration = true;
    theme = "Dracula";
    settings = {
      shell = "${pkgs.zsh}/bin/zsh --interactive --login";
      tab_bar_style = "powerline";
    };
    font = {
      name = "CaskaydiaCove Nerd Font Mono";
      size = 14.0;
    };
  };

  programs.fzf = {
    enable = true;
    defaultCommand = "fd --type file --hidden --no-ignore --exclude .git";
  };

  programs.git.enable = true;

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
