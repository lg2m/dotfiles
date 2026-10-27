{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.my.ai.opencode;
in
{
  options.my.ai.opencode = {
    enable = lib.mkEnableOption "OpenCode AI coding assistant";
  };

  config = lib.mkIf cfg.enable {
    programs.opencode = {
      enable = true;
      themes = {
        rose-pine = ./themes/rose-pine.json;
      };
      agents = {
        git-committer = ./agent/git-committer.md;
        docs = ./agent/docs.md;
        security-review = ./agent/security-review.md;
      };
      commands = ./command;
      # OpenCode 2 terminal settings (cli.json); replaces the v1 tui.json.
      cli = {
        theme.name = "rose-pine";
        mouse = true;
        scroll = {
          speed = 3;
          acceleration = true;
        };
        diffs.view = "auto";
      };
      settings = {
        autoshare = false;
        autoupdate = false;
        plugins = [
          "opencode-wakatime@1.4.0"
          # Keep in step with pkgs/by-name/plannotator.
          "@plannotator/opencode@0.28.33"
        ];
      };
    };

    home.packages = with pkgs; [ bun ];
  };
}
