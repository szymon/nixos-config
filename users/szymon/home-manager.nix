{ config, lib, pkgs, ... }:

let
  # for out MANPAGER env var
  # https://github.com/sharkdp/bat/issues/1145
  manpager = pkgs.writeShellScriptBin "manpager" ''
    cat $1 | col -bx | bat --language man --style plain
  '';

  config = builtins.fetchTarball {
    url = "github.com/szymon/dotfiles/tarball/main";
    # sha256 = "1nlkh5rg4qr7rjzhy2nsngqq9vwzar8grj7dsvxk9dgd9sqgbjvf";
  };
in
{
  home.stateVersion = "18.09";

  home.packages = [
    pkgs.bat
    pkgs.fd
    pkgs.fzf
    pkgs.htop
    pkgs.jq
    pkgs.ripgrep
    pkgs.tree
    pkgs.watch

    pkgs.gopls
    pkgs.pgcli
    pkgs.pspg
    pkgs.go
    pkgs.gcc
    pkgs.cargo
    pkgs.python3
    pkgs.nodejs

    pkgs.alejandra
    pkgs.statix
    pkgs.luarocks
  ];

  home.sessionVariables = {
    LANG = "en_US.UTF-8";
    LC_CTYPE = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
    EDITOR = "nvim";
    PAGER = "less -FirSwX";
    MANPAGER = "${manpager}/bin/manpager";
  };

  programs.git.enable = true;
  programs.direnv.enable = true;
  programs.fish = {
    enable = true;
  };
  programs.neovim.enable = true;
  # programs.neovim.package = pkgs.neovim-nightly;
  programs.tmux.enable = true;


  xdg.configFile."nvim".source = "${config}/nvim_new/.config/nvim";
  xdg.configFile."fish/config.fish".text = builtins.readFile "${config}/fish/.config/fish/config.fish";
  home.file.".tmux.conf".source = "${config}/tmux/dot-tmux.conf";
  home.file.".tmux/tmux.remote.conf".source = "${config}/tmux/dot-tmux/tmux.remote.conf";
  home.file.".gitconfig".source = "${config}/git/dot-gitconfig";
  home.file.".vimrc".source = "${config}/vim/dot-vimrc";

}
