{ lib, config, ... }:
let
  cfg = config.modules.helix;
in
{
  options.modules.helix.enable = lib.mkEnableOption "";

  config = lib.mkIf cfg.enable {
    programs = {
      helix = {
        enable = true;
        defaultEditor = true;
        languages.language = [
          {
            name = "git-commit";
            soft-wrap.enable = true;
          }
        ];
        settings = {
          editor = {
            auto-completion = true;
            auto-format = true;
            bufferline = "multiple";
            completion-replace = true;
            completion-timeout = 100;
            cursorline = true;
            cursor-shape = {
              normal = "block";
              insert = "bar";
              select = "block";
            };
            idle-timeout = 100;
            indent-guides.render = true;
            line-number = "relative";
            lsp = {
              display-inlay-hints = true;
            };
            middle-click-paste = false;
            path-completion = true;
            rulers = [
              80
              100
            ];
            soft-wrap.enable = false;
            statusline = {
              left = [
                "mode"
                "spinner"
              ];
              center = [
                "file-name"
                "read-only-indicator"
                "file-modification-indicator"
              ];
            };
          };
          keys = {
            normal = {
              pageup = "half_page_up";
              pagedown = "half_page_down";
              "C-s" = ":write";
              "C-q" = ":quit";
            };
          };
          theme = "rose_pine";
        };
      };
    };
  };
}
