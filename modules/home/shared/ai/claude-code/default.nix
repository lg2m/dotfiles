{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.modules.ai.claude-code;
in
{
  options.modules.ai.claude-code = {
    enable = lib.mkEnableOption "Claude Code AI coding assistant";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.claude-code ];
  };
}
