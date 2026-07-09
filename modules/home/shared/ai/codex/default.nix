{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.modules.ai.codex;
in
{
  options.modules.ai.codex = {
    enable = lib.mkEnableOption "OpenAI Codex CLI coding assistant";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.codex ];
  };
}
