{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.my.game-development;
in
{
  options.my.game-development.enable = lib.mkEnableOption "game development and art tools";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      aseprite
      blender
    ];
  };
}
