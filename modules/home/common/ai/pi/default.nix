{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.my.ai.pi;
in
{
  options.my.ai.pi = {
    enable = lib.mkEnableOption "Pi coding agent CLI";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.pi-coding-agent ];
  };
}
