# syn0201: corp-managed Linux laptop, standalone Home Manager.
# The OS, ghostty and desktop are managed by IT; we only own ~.
{ config, pkgs, ... }:
{
  imports = [
    ../../users/zmeyer/home.nix
    ../../profiles/home/dev.nix
  ];

  my = {
    ai = {
      plannotator.enable = false;
    };
    fonts.enable = true;
    ghostty = {
      enable = true;
      installPackage = false; # corp-installed; manage config only
    };
  };

  programs.home-manager.enable = true;

  home = {
    stateVersion = "25.05";
    sessionVariables = {
      SHELL = "${config.home.profileDirectory}/bin/zsh";
      TERMINAL = "ghostty";
    };
    packages = with pkgs; [
      audacity
      flameshot
      spotify
    ];
  };
}
