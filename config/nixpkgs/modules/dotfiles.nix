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

      fish = {
        enable = true;
        shellInit = ''
          set -x DOTNET_CLI_TELEMETRY_OPTOUT 1
          set -e TMUX_TMPDIR
          set PATH ~/.local/bin $HOME/.nix-profile/bin ~/.dotnet/tools $PATH
          bind \cp push-line
          bind -m insert \cp push-line

          # for vi mode
          set fish_cursor_default block
          set fish_cursor_insert line
          set fish_cursor_replace_one underscore
          set fish_cursor_visual block
        '' + (if cfg.fish.vi-mode then "fish_vi_key_bindings" else "");
        promptInit = ''
          set -x fish_prompt_pwd_dir_length 80
          omf theme j
        '';
        shellAliases = {
          vi = "vim";
          vim = "nvim";
          ls = "exa $argv";
          ll = "ls -l --sort=modified --reverse";
          cat = "bat -p $argv";
#         grep = "rg --hidden $argv";
          home-manager = "home-manager -f ~/.dotfiles/config/nixpkgs/home.nix";
        };
        functions = {
          push-line = ''
            commandline -f kill-whole-line
            function restore_line -e fish_postexec
              commandline -f yank
              functions -e restore_line
            end'';
        };
      };

      neovim = {
        enable = true;
        plugins = with pkgs.vimPlugins; [
          vim-nix
          vim-fish
          vim-better-whitespace
          vim-commentary
          vim-markdown
          vim-sensible
        ];
        extraConfig = builtins.readFile ../../../vimrc;
      };

      git = {
        enable = true;
        aliases = {
          cl = "clone --recursive";
          su = "submodule update --init --recursive";
          st = "status";
          sw = "switch";
          wdiff = "diff --color-words";
          graph = "log --all --graph --decorate --oneline";
#         new = "!f() { git switch -c ${1} refs/remotes/origin/HEAD; }; f";
        };
#       ignores = ["*~" "*.o" "*.a" "*.dll" "*.bak" "*.old"];
        userName = "Radovan Bast";
        userEmail = "bast@users.noreply.github.com";
        extraConfig = {
          color = {
            diff = "auto";
            status = "auto";
            branch = "auto";
            ui = "auto";
          };
          pager = {
            grep = "off";
            diff = "off";
          };
          core = {
            editor = "vim";
#           pager = "cat";
          };
          apply = {
            whitespace = "nowarn";
          };
          mergetool = {
            keepBackup = false;
            tool = "meld";
          };
          difftool = {
            prompt = false;
          };
          push = {
            default = "simple";
          };
          pull = {
            rebase = false;
          };
          init = {
            defaultBranch = "main";
          };
        };
      };

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
      fish = {
        source = ~/.dotfiles/config/fish;
        target = "fish";
        recursive = true;
      };
      nixpkgs = {
        source = ~/.dotfiles/config/nixpkgs;
        target = "nixpkgs/";
        recursive = true;
      };
    };

    xdg.dataFile = {
      omf = {
        source = ~/.dotfiles/local/share/omf;
        target = "omf";
        recursive = true;
      };
    };

    xdg.dataFile = {
      j = {
        source = ~/.dotfiles/config/fish/themes/r;
        target = "omf/themes/j";
        recursive = false;
      };
      j2 = {
        source = ~/.dotfiles/config/fish/themes/j2;
        target = "omf/themes/j2";
        recursive = false;
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

