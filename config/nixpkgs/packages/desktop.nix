{ pkgs, config, lib, ... }:
with lib;
let
  cfg = config.dotfiles.packages.desktop;

  configuration = {
    nixpkgs.overlays = [
      (import ../overlays/teams.nix)
      (import ../overlays/vscode.nix)
    ];

    dotfiles.packages.desktop = {
      media = mkDefault true;
      x11 = mkDefault true;
      gnome = mkDefault true;
      chat = mkDefault true;
    };

    home.packages = enabledPackages;
  };

  media = with pkgs; [
    obs-studio
#   audacity
#   xf86_input_wacom
#   mpv
  ];

  x11 = with pkgs.xorg; [
    appres
    editres
    listres
    viewres
    luit
    xdpyinfo
    xdriinfo
    xev
    xfd
    xfontsel
    xkill
    xlsatoms
    xlsclients
    xlsfonts
    xmessage
    xprop
    xvinfo
    xwininfo
    xmessage
    xvinfo
    xmodmap
    pkgs.glxinfo
    pkgs.xclip
    pkgs.xsel
  ];

  gnome = with pkgs.gnome3; [
    gnome-settings-daemon
    gnome-font-viewer
    adwaita-icon-theme
    gnome-themes-extra
    evince
    gnome-calendar
    gnome-bluetooth
    seahorse
    nautilus
    dconf
    gnome-disk-utility
    gnome-tweaks
    eog
    networkmanager-fortisslvpn
    gnome-keyring
    dconf-editor
    pkgs.desktop-file-utils
    pkgs.gcolor3
  ];

  desktop = with pkgs; [
  ];

  chat = with pkgs; [
    teams
    signal-desktop
    slack
  ];

  useIf = x: y: if x then y else [];

  enabledPackages =
    desktop ++
    useIf cfg.gnome gnome ++
    useIf cfg.x11 x11 ++
    useIf cfg.media media ++
    useIf cfg.chat chat;

in {
  options.dotfiles.packages.desktop = {
    enable = mkEnableOption "Enable desktop packages";
    media = mkEnableOption "Enable media packages";
    chat = mkEnableOption "Enable chat clients";
    x11 = mkEnableOption "Enable x11 packages";
    gnome = mkEnableOption "Enable gnome packages";
  };

  config = mkIf cfg.enable (mkMerge [
    configuration
 ]);

}
