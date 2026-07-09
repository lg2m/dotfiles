{
  lib,
  config,
  pkgs,
  ...
}:
let
  hyprCfg = config.modules.hyprland;
  cfg = config.modules.hyprland.yofi;
in
{
  options.modules.hyprland.yofi = {
    enable = (lib.mkEnableOption "Enable yofi launcher for Hyprland sessions.") // {
      default = true;
    };
  };

  config = lib.mkIf (hyprCfg.enable && cfg.enable) {
    home.packages = [ pkgs.yofi ];

    xdg.configFile."yofi/yofi.config".source = ./yofi.config;

    wayland.windowManager.hyprland.settings = {
      bind = [
        "$mod, SPACE, exec, yofi"
      ];
    };
  };
}
