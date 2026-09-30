{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.modules.ai.executor;
in
{
  options.modules.ai.executor = {
    enable = lib.mkEnableOption "Executor local CLI for AI tool integrations";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.executor ];
  };
}
