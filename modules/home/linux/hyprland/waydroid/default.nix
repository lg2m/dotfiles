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
    my.hyprland = {
      binds = [
        {
          keys = "${hyprCfg.mod} + A";
          exec = "waydroid show-full-ui";
          execRules = lib.optionalAttrs (cfg.workspace != null) {
            workspace = toString cfg.workspace;
          };
        }
        {
          keys = "${hyprCfg.mod} + SHIFT + A";
          exec = "waydroid session stop";
        }
      ];

      windowRules = [
        # Full UI (class "Waydroid"): don't idle-lock mid-game.
        (
          {
            name = "waydroid-full-ui";
            match.class = "^(Waydroid)$";
            idle_inhibit = "always";
          }
          // lib.optionalAttrs cfg.fullscreen { fullscreen = true; }
        )
        # Multi-window mode (`waydroid prop set persist.waydroid.multi_windows true`)
        # names each app window "waydroid.<package>"; float them like phone windows.
        {
          name = "waydroid-app-windows";
          match.class = "^(waydroid\\..*)$";
          float = true;
          center = true;
          idle_inhibit = "focus";
        }
      ];
    };
  };
}
