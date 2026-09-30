{
  lib,
  config,
  pkgs,
  ...
}:
let
  hyprCfg = config.my.hyprland;
  cfg = config.my.hyprland.hyprlock;
in
{
  options.my.hyprland.hyprlock = {
    enable = (lib.mkEnableOption "Enable hyprlock screen locking for Hyprland sessions.") // {
      default = true;
    };
  };

  config = lib.mkIf (hyprCfg.enable && cfg.enable) {
    home.packages = [ pkgs.hyprlock ];

    xdg.configFile."hypr/hyprlock.conf".source = ./hyprlock.conf;
    xdg.configFile."hypr/hyprlock-theme.conf".source = ./hyprlock-theme.conf;

    wayland.windowManager.hyprland.settings = {
      bind = [
        "$mod SHIFT, X, exec, hyprlock"
      ];
    };
  };
}
