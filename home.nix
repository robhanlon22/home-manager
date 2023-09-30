{ pkgs, lib, ... }:

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

    pkgs.curl
    pkgs.fd
    pkgs.gcc
    pkgs.gh
    pkgs.gnumake
    pkgs.jq
    pkgs.lame
    pkgs.libyaml
    pkgs.pre-commit
    pkgs.ruby
    pkgs.wormhole-william
    pkgs.zsh-powerlevel10k

    # LSP
    pkgs.lua-language-server
    pkgs.nil
  ];

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
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
    initExtra = ''
      source '${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme'
      ${builtins.readFile ./etc/zsh/p10k.zsh}
    '';
    shellAliases = {
      ls = "ls --color";
      hm = "home-manager";
      hms = "hm switch";
      hmb = "hm build";
      wormhole = "wormhole-william";
    };
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
    };
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
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
