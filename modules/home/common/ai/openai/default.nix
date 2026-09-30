{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.my.ai.openai;
in
{
  options.my.ai.openai = {
    # pkgs.codex is pinned ahead of nixpkgs in pkgs/by-name/codex.
    codex.enable = lib.mkEnableOption "OpenAI Codex CLI coding assistant";

    # Unofficial repackaging of OpenAI's signed Linux ChatGPT/Codex desktop app
    # (github:ilysenko/codex-desktop-linux). Uses the Codex CLI bundled with the
    # desktop payload so the app/CLI protocol versions always match.
    desktop.enable = lib.mkEnableOption "ChatGPT/Codex desktop app (codex-desktop, Linux only)";
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.codex.enable {
      home.packages = [ pkgs.codex ];
    })
    (lib.mkIf cfg.desktop.enable {
      assertions = [
        {
          assertion = pkgs.stdenv.hostPlatform.isLinux;
          message = "my.ai.openai.desktop is Linux-only; on macOS install the official app.";
        }
      ];
      home.packages = [ pkgs.codex-desktop ];
    })
  ];
}
