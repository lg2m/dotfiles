{ lib, ... }:
{
  my = {
    steam.enable = lib.mkDefault true;
    gamemode.enable = lib.mkDefault false;
    gamescope.enable = lib.mkDefault false;
  };
}
