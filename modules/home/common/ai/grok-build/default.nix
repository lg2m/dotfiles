{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.modules.ai.grok-build;
in
{
  options.modules.ai.grok-build = {
    enable = lib.mkEnableOption "Grok Build AI coding assistant";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.grok-build ];
  };
}
