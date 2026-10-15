{
  lib,
  config,
  ...
}:
let
  hyprCfg = config.my.hyprland;
  cfg = config.my.hyprland.waydroid;
in
{
  options.my.hyprland.waydroid = {
    enable = lib.mkEnableOption "Hyprland binds and window rules for Waydroid (needs my.waydroid on the system)";

    workspace = lib.mkOption {
      type = lib.types.nullOr (lib.types.ints.between 1 10);
      default = 6;
      description = "Workspace the full Waydroid UI opens on (null = current workspace).";
    };

    fullscreen = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Open the full Waydroid UI fullscreen (otherwise tiled; toggle with $mod F).";
    };
  };

  config = lib.mkIf (hyprCfg.enable && cfg.enable) {
    wayland.windowManager.hyprland.settings = {
      bind = [
        "$mod, A, exec, ${
          lib.optionalString (cfg.workspace != null) "[workspace ${toString cfg.workspace}] "
        }waydroid show-full-ui"
        "$mod SHIFT, A, exec, waydroid session stop"
      ];

      windowrule = [
        # Full UI (class "Waydroid"): don't idle-lock mid-game.
        "match:class ^(Waydroid)$, idle_inhibit always${lib.optionalString cfg.fullscreen ", fullscreen on"}"
        # Multi-window mode (`waydroid prop set persist.waydroid.multi_windows true`)
        # names each app window "waydroid.<package>"; float them like phone windows.
        "match:class ^(waydroid\\..*)$, float on, center on, idle_inhibit focus"
      ];
    };
  };
}
