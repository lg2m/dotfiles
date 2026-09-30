{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.modules.ai.opencode;
in
{
  options.modules.ai.opencode = {
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
      tui = {
        theme = "rose-pine";
        scroll_speed = 3;
        scroll_acceleration = {
          enable = true;
        };
        diff_style = "auto";
        mouse = true;
      };
      settings = {
        autoshare = false;
        autoupdate = false;
        plugin = [
          "opencode-wakatime"
          "@plannotator/opencode"
        ];
      };
    };

    home.packages = with pkgs; [ bun ];
  };
}
