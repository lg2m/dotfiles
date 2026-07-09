{
  lib,
  config,
  pkgs,
  ...
}:
let
  hyprCfg = config.modules.hyprland;
  cfg = config.modules.hyprland.clipboard;
  yaziEnabled = config.modules.yazi.enable;
in
{
  options.modules.hyprland.clipboard = {
    enable = (lib.mkEnableOption "Enable Wayland clipboard utilities for Hyprland sessions.") // {
      default = true;
    };
  };

  config = lib.mkIf (hyprCfg.enable && cfg.enable) {
    home.packages = lib.optionals (!yaziEnabled) [
      pkgs.wl-clipboard-rs
    ];
  };
}
