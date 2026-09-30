{
  lib,
  config,
  ...
}:
let
  cfg = config.my.ai;
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

  options.my.ai = {
    enable = lib.mkEnableOption "AI coding tools (Herdr, OpenCode, Plannotator, Executor, etc.)";
  };

  config = lib.mkIf cfg.enable {
    # The top-level enable gate is intentionally a no-op beyond gating sub-modules.
    # Enable individual tools via my.ai.opencode.enable, my.ai.claude-code.enable, etc.
  };
}
