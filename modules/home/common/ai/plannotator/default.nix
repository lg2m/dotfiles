{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.modules.ai.plannotator;
in
{
  options.modules.ai.plannotator = {
    enable = lib.mkEnableOption "Plannotator interactive code review tool";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.plannotator ];
  };
}
