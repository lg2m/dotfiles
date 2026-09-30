{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.modules.ai.herdr;
in
{
  options.modules.ai.herdr = {
    enable = lib.mkEnableOption "Herdr terminal workspace manager for AI coding agents";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.herdr ];
  };
}
