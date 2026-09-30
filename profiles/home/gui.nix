# Machine with a graphical session: fonts, terminal, desktop apps.
{ lib, pkgs, ... }:
{
  my = {
    fonts.enable = lib.mkDefault true;
    ghostty.enable = lib.mkDefault true;
  };

  home.packages = with pkgs; [
    audacity
    spotify
  ];
}
