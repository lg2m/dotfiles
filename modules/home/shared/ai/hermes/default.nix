{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.modules.ai.hermes;
in
{
  options.modules.ai.hermes = {
    enable = lib.mkEnableOption "Hermes AI agent";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.hermes ];
  };
}
