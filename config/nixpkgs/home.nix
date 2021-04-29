{pkgs, lib, ...}:
{
  dotfiles = {
    desktop = {
      enable = true;
      dropbox.enable = false;
      polybar = {
      	interface = "eno2";
      	laptop = false;
      };
    };
    packages = {
      devel = {
        enable = true;
        nix = true;
        db = false;
        dotnet = true;
        node = true;
        rust = true;
        haskell = false;
        python = true;
        go = false;
        java = false;
        clojure = false;
      };
      desktop = {
        enable = true;
        gnome = true;
        x11 = true;
        media = true;
        chat = true;
        graphics = true;
        wavebox = false;
        zoom = true;
      };
      kubernetes = true;
      cloud = true;
      geo = false;
    };
    extraDotfiles = [
      # "bcrc"
      # "ghci"
      # "haskeline"
    ];
  };

  home.packages = with pkgs; [];

  programs = {
    git = {
      signing = {
        key = "bast";
      };
    };
  };

  imports = [ ./modules ];
}
