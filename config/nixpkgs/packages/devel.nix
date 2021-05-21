{ pkgs, config, lib, ... }:
with lib;
let
  cfg = config.dotfiles.packages;

  all-hies = import (fetchTarball "https://github.com/infinisil/all-hies/tarball/master") {};
  hie = all-hies.selection { selector = p: { inherit (p) ghc865; }; };

  configuration = {
    nixpkgs.overlays = [ (import ../overlays/dotnet-sdk.nix) ];

    dotfiles.packages.devel = {
      nix = mkDefault true;
    };

    home.packages = enabledPackages;
  };

  base = with pkgs; [
  ];

  dotnet = {
    home.sessionVariables = {
      DOTNET_ROOT = pkgs.dotnetCorePackages.sdk_5_0;
    };
    home.packages = [
      pkgs.dotnetCorePackages.sdk_5_0
    ];
  };

  python = with pkgs; [
    (python3.withPackages (ps: with ps; [
        numpy
        matplotlib
#       tkinter
        virtualenv
        click
      ]))
  ];

  nix = with pkgs; [
    niv
    lorri
    nix-prefetch-scripts
    patchelf
  ];

  useIf = x: y: if x then y else [];

  enabledPackages =
    base ++
    useIf cfg.devel.python python ++
    useIf cfg.devel.nix nix;
in {
  options.dotfiles.packages = {
    devel = {
      enable = mkEnableOption "Enable development packages";
      dotnet = mkEnableOption "Enable dotnet sdk";
      nix = mkEnableOption "Enable nix";
      python = mkEnableOption "Enable Python";
    };
  };

  config = mkIf cfg.devel.enable (mkMerge [
    configuration
    (mkIf cfg.devel.dotnet dotnet)
  ]);

}
