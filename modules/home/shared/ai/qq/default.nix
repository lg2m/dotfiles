{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.modules.ai.qq;
in
{
  options.modules.ai.qq = {
    enable = lib.mkEnableOption "QQ terminal-native agent harness";

    model = lib.mkOption {
      type = lib.types.str;
      default = "xai/grok-4.6";
      description = "Default QQ provider/model route";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.qq ];

    xdg.configFile."qq/config.ron".text = ''
      (
        version: 1,
        model: "${cfg.model}",
      )
    '';
  };
}
