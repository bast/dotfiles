{ pkgs, config, lib, ...}:
with lib;
let
  cfg = config.dotfiles.desktop.i3;

  configuration = {
    # home.file.xmobarrc = {
    #   source = ~/.xmonad/xmobarrc;
    #   target = ".xmobarrc";
    #   recursive = false;
    # };

    # xdg.dataFile = {
    #   xmonad-desktop = {
    #     source = ~/.xmonad/Xmonad.desktop;
    #     target = "applications/Xmonad.desktop";
    #   };
    # };

    dotfiles.desktop.polybar.enable = mkDefault false;

    xsession = {
      enable = true;
      initExtra = ''
        xsetroot -solid '#888888'
        xsetroot -cursor_name left_ptr
        ${pkgs.gnome3.gnome-settings-daemon}/libexec/gsd-xsettings &
        systemctl --user start gvfs-udisks2-volume-monitor.service
        xset s 1800
        xset +dpms
        xset dpms 1800 2400 3600
        xmodmap $HOME/.dotfiles/Xmodmap
        xrandr --output HDMI-3 --left-of DP-1
      '';

      windowManager.i3 = {
        enable = true;
        config = {
          window.titlebar = false;
          terminal = "termite";
          modifier = "Mod4";  # this is the "windows" key
        };
      };
    };

    home.packages = with pkgs; [];
  };
in {
  options.dotfiles.desktop.i3 = {
    enable = mkEnableOption "Enable i3";
  };

  config = mkIf cfg.enable configuration;

  imports = [ ./polybar.nix ];
}

