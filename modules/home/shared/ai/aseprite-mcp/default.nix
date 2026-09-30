{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.modules.ai.aseprite-mcp;
in
{
  options.modules.ai.aseprite-mcp = {
    enable = lib.mkEnableOption "Aseprite MCP integration for pixel-art tools";
    workspace = lib.mkOption {
      type = lib.types.str;
      default = "${config.home.homeDirectory}/Pictures/aseprite";
      description = "Directory containing artwork accessible to the Aseprite MCP server.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.aseprite-mcp ];

    # Codex owns its mutable config. Update only this server using its CLI,
    # preserving authentication, trusted projects, and other integrations.
    home.activation.asepriteMcp = lib.mkIf config.modules.ai.openai.codex.enable (
      lib.hm.dag.entryAfter [ "linkGeneration" ] ''
        run ${pkgs.coreutils}/bin/mkdir -p ${lib.escapeShellArg cfg.workspace}
        run ${config.home.profileDirectory}/bin/codex mcp add aseprite \
          --env ${lib.escapeShellArg "ASEPRITE_MCP_WORKSPACE=${cfg.workspace}"} \
          --env ASEPRITE_MCP_ALLOW_ABSOLUTE=0 \
          -- ${lib.getExe pkgs.aseprite-mcp}
      ''
    );
  };
}
