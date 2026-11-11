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

    my.hyprland.binds = [
      {
        keys = "${hyprCfg.mod} + SHIFT + X";
        exec = "hyprlock";
      }
    ];

    # hyprlock 0.9.6 aborts when an output disappears under it (the G95C
    # reports DPMS-off as a disconnect; hyprwm/hyprlock#984). Let a fresh
    # hyprlock take over the dead lock instead of needing
    # `hyprctl eval 'hl.clear_crashed_lockscreen()'`.
    wayland.windowManager.hyprland.settings.config.misc.allow_session_lock_restore = true;
  };
}
