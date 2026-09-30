{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.modules.game-development;
in
{
  options.modules.game-development.enable = lib.mkEnableOption "game development and art tools";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      aseprite
      blender
    ];
  };
}
