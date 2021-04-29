{ pkgs, config, lib, ... }:
with lib;
let
  cfg = config.dotfiles.packages.desktop;

  configuration = {
    nixpkgs.overlays = [
      (import ../overlays/wavebox.nix)
      (import ../overlays/teams.nix)
      (import ../overlays/vscode.nix)
    ];

    dotfiles.packages.desktop = {
      media = mkDefault true;
      x11 = mkDefault true;
      gnome = mkDefault true;
      chat = mkDefault true;
      graphics = mkDefault true;
    };

    home.packages = enabledPackages;
  };

  media = with pkgs; [
    inkscape
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

  graphics = with pkgs; [
    imagemagick
#   inkscape
  ];

  desktop = with pkgs; [
    google-chrome
    firefox
    tree
    pulsemixer
    tldr
    rdesktop
    pass
    blueman
    gparted
    keybase
    keybase-gui
    pandoc
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
    useIf cfg.chat chat ++
    useIf cfg.graphics graphics ++
    useIf cfg.wavebox [ pkgs.wavebox ] ++
    useIf cfg.zoom [ pkgs.zoom-us ];

in {
  options.dotfiles.packages.desktop = {
    enable = mkEnableOption "Enable desktop packages";
    media = mkEnableOption "Enable media packages";
    chat = mkEnableOption "Enable chat clients";
    x11 = mkEnableOption "Enable x11 packages";
    gnome = mkEnableOption "Enable gnome packages";
    graphics = mkEnableOption "Enable graphics packages";
    wavebox = mkEnableOption "Enable wavebox";
    zoom = mkEnableOption "Enable zoom";
  };

  config = mkIf cfg.enable (mkMerge [
    configuration
 ]);

}
