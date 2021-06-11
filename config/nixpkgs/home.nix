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
    rust_packages ++
    node_packages ++
    cl_packages ++
    build_packages;

  programs = {
    git = {
      signing = {
        key = "bast";
      };
    };



  };

  imports = [ ./modules ];
}
