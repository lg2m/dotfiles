{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.my.ai.qq;
in
{
  options.my.ai.qq = {
    enable = lib.mkEnableOption "QQ terminal-native agent harness";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.qq ];
  };
}
