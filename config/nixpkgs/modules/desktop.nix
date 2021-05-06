{ pkgs, config, lib, ... }:
with lib;
let
  cfg = config.dotfiles.desktop;

  configuration = {
    dotfiles.packages.desktop.enable = mkDefault true;

    dotfiles.desktop.i3.enable = mkDefault true;

    programs = {
      gpg = {
        enable = true;
        settings = {
          use-agent = true;
        };
      };
    };

    home.file = {
      icons = {
        source = ~/.dotfiles/icons;
        target = ".icons";
        recursive = true;
      };
      xmodmap = {
        source = ~/.dotfiles/Xmodmap;
        target = ".Xmodmap";
        recursive = false;
      };
    };

    services = {
      pasystray.enable = true;
      flameshot.enable =  true;
      clipmenu.enable =  true;

      screen-locker = {
        enable = true;
        inactiveInterval = 45;
        lockCmd = "${pkgs.i3lock}/bin/i3lock -n -c 444444";
      };

      network-manager-applet.enable = true;
      blueman-applet.enable = true;

      gpg-agent = {
        enable = true;
#       enableSshSupport = true;
        defaultCacheTtl = 43200; # 12 hours
#       defaultCacheTtlSsh = 43200;
        maxCacheTtl = 604800; # 7 days
#       maxCacheTtlSsh = 604800;
        pinentryFlavor = "gnome3";
      };

      gnome-keyring = {
        enable = true;
        components = [ "pkcs11" "secrets" ];
      };
    };

    systemd.user.sessionVariables = {
      GIO_EXTRA_MODULES = "${pkgs.gvfs}/lib/gio/modules";
    };

    gtk = {
      enable = true;
      font.name = "DejaVu Sans 11";
      iconTheme.name = "Ubuntu-mono-dark";
      theme.name = "Adwaita";
      gtk3.extraConfig = { gtk-application-prefer-dark-theme = 0; };
    };

    xresources.properties = {
      "Xclip.selection" = "clipboard";
      "Xcursor.theme" = "cursor-theme";
      "Xcursor.size" = 16;
    };

    programs.vscode = {
      enable = true;
      extensions = [];
      haskell = {
        enable = false;
        hie.enable = false;
      };
      userSettings = {
      };
    };

    programs.termite = {
      enable = true;
      clickableUrl = false;
      font = "Monospace 10";
      foregroundColor         = "#d8d8d8";
      foregroundBoldColor     = "#e8e8e8";
      cursorColor             = "#e8e8e8";
      cursorForegroundColor   = "#181818";
      #backgroundColor        = "rgba(24, 24, 24, 1)";
      colorsExtra = ''
        # Base16 Default Dark
        # Author: Chris Kempson (http://chriskempson.com)

        # Black, Gray, Silver, White
        color0  = #0b1c2c
        #color0  = #181818
        color8  = #585858
        color7  = #d8d8d8
        color15 = #f8f8f8

        # Red
        color1  = #ab4642
        color9  = #ab4642

        # Green
        color2  = #a1b56c
        color10 = #a1b56c

        # Yellow
        color3  = #f7ca88
        color11 = #f7ca88

        # Blue
        color4  = #7cafc2
        color12 = #7cafc2

        # Purple
        color5  = #ba8baf
        color13 = #ba8baf

        # Teal
        color6  = #86c1b9
        color14 = #86c1b9

        # Extra colors
        color16 = #dc9656
        color17 = #a16946
        color18 = #282828
        color19 = #383838
        color20 = #b8b8b8
        color21 = #e8e8e8
      '';
    };
  };

in
{
  options.dotfiles.desktop = {
    enable = mkEnableOption "Enable desktop";
  };

  config = mkIf cfg.enable configuration;

  imports = [ ./i3.nix ];
}
