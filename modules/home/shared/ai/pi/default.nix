{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.modules.ai.pi;
in
{
  options.modules.ai.pi = {
    enable = lib.mkEnableOption "Pi coding agent CLI";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.pi-coding-agent ];
  };
}
