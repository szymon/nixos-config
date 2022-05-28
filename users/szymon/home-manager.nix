{ pkgs, ... }: {
  xdg.enable = true;

  home.packages = with pkgs; [
    efm-langserver
    firefox
    go
    gopls
    kubectl
    kubeseal
    neovim
    nodejs
    rofi
    sumneko-lua-language-server
    nixpkgs-fmt
    rnix-lsp
    luaformatter
    feh
  ];

  home.sessionVariables = {
    LANG = "en_US.UTF-8";
    LC_CTYPE = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
    EDITOR = "nvim";
    PAGER = "less -FirSwX";
    MANPAGER = "sh -c 'col -bx | ${pkgs.bat}/bin/bat -l man -p'";
  };

  home.file.".inputrc".source = ./inputrc;
  home.file.".gitconfig".source = ./gitconfig;
  home.file.".vimrc".source = ./vimrc;

  home.file.".local/share/nvim/site/pack/packer/start/packer.nvim" = {
    source = builtins.fetchGit {
      url = "https://github.com/wbthomason/packer.nvim";
      rev = "4dedd3b08f8c6e3f84afbce0c23b66320cd2a8f2";
    };
  };

  xdg.configFile = {
    "i3/config".text = builtins.readFile ./i3;

    nvim = {
      source = ./nvim;
      recursive = true;
    };
  };

  programs = {
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    fish.enable = true;
    tmux.enable = true;

    i3status = {
      enable = true;
      general = {
        colors = true;
        color_good = "#8C9440";
        color_bad = "#A54242";
        color_degraded = "#DE935F";
      };

      modules = {
        ipv6.enable = false;
        "wireless _first_".enable = false;
        "battery all".enable = false;
      };

    };

    kitty = {
      enable = true;
      extraConfig = builtins.readFile ./kitty;
    };


  };

  xresources.extraConfig = builtins.readFile ./Xresources;

  home.pointerCursor = {
    x11.enable = true;
    name = "Vanilla-DMZ";
    package = pkgs.vanilla-dmz;
    size = 24;
  };
}

# vim: set ts=2 sw=2 expandtab :
