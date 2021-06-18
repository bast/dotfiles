{ config, lib, pkgs, ...}:
with lib;
let
  cfg = config.dotfiles;

  configuration = {
    manual.manpages.enable = true;

    programs = {
      man.enable = true;
      lesspipe.enable = false;
      dircolors.enable = true;

      tmux = {
        enable = true;
        baseIndex = 1;
        clock24 = true;
        escapeTime = 10;
        terminal = "tmux-256color";
        historyLimit = 5000;
        keyMode = "vi";
        plugins = with pkgs; [
          (tmuxPlugins.mkTmuxPlugin {
            pluginName = "statusbar";
            version = "1.0";
            src = ../../../tmux-plugins;
          })
          (tmuxPlugins.mkTmuxPlugin {
            pluginName = "current-pane-hostname";
            version = "master";
            src = fetchFromGitHub {
              owner = "soyuka";
              repo = "tmux-current-pane-hostname";
              rev = "6bb3c95250f8120d8b072f46a807d2678ecbc97c";
              sha256 = "1w1x8w351v9yppw37kcs985mm5ikpmdnckfjwqyhlqx90lf9sqdy";
            };
          })
          (tmuxPlugins.mkTmuxPlugin {
            pluginName = "simple-git-status";
            version = "master";
            src = fetchFromGitHub {
              owner = "kristijanhusak";
              repo = "tmux-simple-git-status";
              rev = "287da42f47d7204618b62f2c4f8bd60b36d5c7ed";
              sha256 = "04vs4afxcr118p78mw25nnzvlms7pmgmi2a80h92vw5pzw9a0msq";
            };
          })
        ];
        extraConfig = ''
          # start windows and panes at 1
          setw -g pane-base-index 1
          set -ga terminal-overrides ",xterm-termite:Tc"
          set-option -g default-shell ${pkgs.fish}/bin/fish
        '';
      };

      htop = {
        enable = true;
        settings.left_meter_modes = [ "AllCPUs4" "Memory" "Swap" ];
        settings.right_meter_modes = [ "Tasks" "LoadAverage" "Uptime" ];
      };


      home-manager = {
        enable = true;
        path = "https://github.com/nix-community/home-manager/archive/release-21.05.tar.gz";
      };
    };

    home.keyboard = {
      layout = "us(altgr-intl)";
      model = "pc104";
      options = [
        "eurosign:e"
        "caps:none"
      ];
    };

    home.sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      KUBE_EDITOR = "nvim";
      LESS = "-MiScR";
      GIT_ALLOW_PROTOCOL = "ssh:https:keybase:file";
      LD_LIBRARY_PATH = "$HOME/.nix-profile/lib";
    };

    systemd.user.startServices = true;

    systemd.user.sessionVariables = {
      GIT_ALLOW_PROTOCOL = "ssh:https:keybase:file";
    };


    nixpkgs.config = {
      allowUnfree = true;
    };

    xdg.configFile = {
      # fish = {
      #   source = ~/.dotfiles/config/fish;
      #   target = "fish";
      #   recursive = true;
      # };
      nixpkgs = {
        source = ~/.dotfiles/config/nixpkgs;
        target = "nixpkgs/";
        recursive = true;
      };
    };

    services.unison = {
      enable = false;
      pairs = {
        docs = [ "/home/$USER/Documents"  "ssh://example/Documents" ];
      };
    };
  };

  # settings when not running under NixOS
  plainNix = {
    home.sessionVariables = {
      SSH_AUTH_SOCK = "$HOME/.gnupg/S.gpg-agent.ssh";
      NIX_PATH = "$HOME/.nix-defexpr/channels/:$NIX_PATH";
    };

    services = {
      gpg-agent = {
        enable = true;
        enableSshSupport = true;
        defaultCacheTtl = 43200; # 12 hours
        defaultCacheTtlSsh = 64800; # 18 hours
        maxCacheTtl = 64800;
        maxCacheTtlSsh = 64800;
        pinentryFlavor = "curses";
      };
    };
  };
in
{
  options.dotfiles = {
    plainNix = mkEnableOption "Tweaks for non-NixOS systems";

    fish.vi-mode = mkEnableOption "Enable vi-mode for fish";
  };

  config = mkMerge [
    configuration
  ];
}

