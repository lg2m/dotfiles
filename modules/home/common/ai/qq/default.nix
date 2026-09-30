{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.modules.ai.qq;
in
{
  options.modules.ai.qq = {
    enable = lib.mkEnableOption "QQ terminal-native agent harness";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.qq ];
  };
}
