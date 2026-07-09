{
  lib,
  config,
  pkgs,
  ...
}:
let
  hyprCfg = config.modules.hyprland;
  cfg = config.modules.hyprland.screenshot;
in
{
  options.modules.hyprland.screenshot = {
    enable = (lib.mkEnableOption "Enable screenshot tooling for Hyprland sessions.") // {
      default = true;
    };
  };

  config = lib.mkIf (hyprCfg.enable && cfg.enable) {
    home.sessionVariables.HYPRSHOT_DIR = "${config.home.homeDirectory}/Pictures/Screenshots";

    home.packages = [
      pkgs.hyprshot
      pkgs.grim
      pkgs.slurp
      pkgs.wl-clipboard-rs
      pkgs.libnotify
    ];

    wayland.windowManager.hyprland.settings = {
      bind = [
        "$mod SHIFT, S, exec, hyprshot -m region"
        "$mod CTRL, S, exec, hyprshot -m window"
        "$mod ALT, S, exec, hyprshot -m output"
      ];
    };
  };
}
