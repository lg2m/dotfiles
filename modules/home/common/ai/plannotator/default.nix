{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.my.ai.plannotator;
in
{
  options.my.ai.plannotator = {
    enable = lib.mkEnableOption "Plannotator interactive code review tool";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.plannotator ];
  };
}
