{ lib, config, ... }:
let
  cfg = config.modules.fzf;
in
{
  options.modules.fzf.enable = lib.mkEnableOption "";

  config = lib.mkIf cfg.enable {
    programs.fzf = {
      changeDirWidget.options = [ "--preview 'eza -la --group-directories-first --icons {}'" ];
      colors = {
        fg = "#908caa";
        "fg+" = "#e0def4";
        bg = "#232136";
        "bg+" = "#393552";
        hl = "#ea9a97";
        "hl+" = "#ea9a97";
        border = "#44415a";
        header = "#3e8fb0";
        gutter = "#232136";
        spinner = "#f6c177";
        info = "#9ccfd8";
        pointer = "#c4a7e7";
        marker = "#eb6f92";
        prompt = "#908caa";
      };
      defaultOptions = [
        "--height=40%"
        "--layout=reverse"
        "--border"
      ];
      enable = true;
      enableZshIntegration = true;
      fileWidget.options = [ "--preview 'bat --style=numbers --color=always --line-range=:500 {}'" ];
      historyWidget.options = [ "--sort" ];
    };
  };
}
