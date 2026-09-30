{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.my.ai.herdr;
in
{
  options.my.ai.herdr = {
    enable = lib.mkEnableOption "Herdr terminal workspace manager for AI coding agents";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.herdr ];
  };
}
