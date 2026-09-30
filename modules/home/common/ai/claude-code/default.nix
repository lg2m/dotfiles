{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.my.ai.claude-code;
in
{
  options.my.ai.claude-code = {
    enable = lib.mkEnableOption "Claude Code AI coding assistant";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.claude-code ];
  };
}
