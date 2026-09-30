{
  lib,
  config,
  pkgs,
  ...
}:
let
  hyprCfg = config.my.hyprland;
  cfg = config.my.hyprland.mako;
in
{
  options.my.hyprland.mako = {
    enable = (lib.mkEnableOption "Enable Mako notifications for Hyprland sessions.") // {
      default = true;
    };
  };

  config = lib.mkIf (hyprCfg.enable && cfg.enable) {
    home.packages = [ pkgs.mako ];

    xdg.configFile."mako/config".source = ./config;

    wayland.windowManager.hyprland.settings = {
      "exec-once" = [
        "mako"
      ];
    };
  };
}
