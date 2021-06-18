{ pkgs, ... }:

let
  base_packages = with pkgs; [
    blueman
    firefox
    google-chrome
    gparted
    gnupg
    keybase
    keybase-gui
    pandoc
    pass
    pulsemixer
    rdesktop
    zoom-us
    imagemagick
    inkscape
    meld
    git
  ];

# container_packages = with pkgs; [
#   singularity
#   squashfsTools
# ];

  rust_packages = with pkgs; [
    cargo
    rustc
    rustfmt
    rustPackages.clippy
  ];

  build_packages = with pkgs; [
    binutils
    gcc
    gdb
    gnumake
    cmake
    automake
    autoconf
    libtool
    squashfsTools
  ];

  node_packages = with pkgs; [
    nodejs
    nodePackages.npm
    nodePackages.yarn
    nodePackages.webpack
  ];

  cl_packages = with pkgs; [
    exa
    ripgrep
    fd
    bat
    sshuttle
    htop
    tldr
    tree
  ];

in {
  dotfiles = {
    desktop = {
      enable = true;
    };
    packages = {
      devel = {
        enable = true;
        nix = true;
        dotnet = true;
        python = true;
      };
      desktop = {
        enable = true;
        gnome = true;
        x11 = true;
        media = true;
        chat = true;
      };
    };
  };

  home.packages =
    base_packages ++
#   container_packages ++
    rust_packages ++
    node_packages ++
    cl_packages ++
    build_packages;

  programs.alacritty.enable = true;

  nixpkgs.config = {
    allowUnfree = true;
  };

  programs.fish = {
    enable = true;
    promptInit = ''
      set -x fish_prompt_pwd_dir_length 80
    '';
    shellAliases = {
      vi = "vim";
      ls = "exa";
      ll = "ls -l --sort=modified --reverse";
      cat = "bat";
    };
  };

  xdg.configFile = {
    fish = {
      source = ../../fish;
      target = "fish";
      recursive = true;
    };
  };

  programs.vim = {
    enable = true;
    extraConfig = builtins.readFile ../../vimrc;
    plugins = with pkgs.vimPlugins; [
      vim-nix
      vim-fish
      vim-better-whitespace
      vim-commentary
      vim-markdown
      vim-sensible
      vim-colorschemes
      rainbow
    ];
  };

  home.file.".gitconfig".source = ../../gitconfig;
  home.file.".alacritty.yml".source = ../../alacritty.yml;

  imports = [ ./modules ];
}
