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
      # The only global config. Project-specific settings (providers, keys,
      # models) go in each repo's .opencode/opencode.json, which is ignored
      # globally by modules/home/common/vcs/git.
      settings = {
        # Nix pins the binary and plugin versions.
        update = "disable";
        share = "disabled";
        formatter = true;
        permissions = [
          {
            action = "shell";
            resource = "rm -rf *";
            effect = "ask";
          }
        ];
        experimental = {
          background_compaction = true;
          subagent_depth = 2;
          todo = true;
        };
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
