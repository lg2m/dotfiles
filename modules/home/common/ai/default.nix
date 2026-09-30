{
  lib,
  config,
  ...
}:
let
  cfg = config.modules.ai;
in
{
  imports = [
    ./aseprite-mcp
    ./claude-code
    ./executor
    ./grok-build
    ./herdr
    ./openai
    ./opencode
    ./pi
    ./plannotator
    ./qq
  ];

  options.modules.ai = {
    enable = lib.mkEnableOption "AI coding tools (Herdr, OpenCode, Plannotator, Executor, etc.)";
  };

  config = lib.mkIf cfg.enable {
    # The top-level enable gate is intentionally a no-op beyond gating sub-modules.
    # Enable individual tools via modules.ai.opencode.enable, modules.ai.claude-code.enable, etc.
  };
}
