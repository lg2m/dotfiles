# Baseline for every Mac.
{ lib, ... }:
{
  my = {
    core.enable = lib.mkDefault true;
    macos.enable = lib.mkDefault true;
  };

  programs.zsh.enable = lib.mkDefault true;
}
