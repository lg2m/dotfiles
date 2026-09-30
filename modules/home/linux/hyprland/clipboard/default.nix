{
  lib,
  config,
  pkgs,
  ...
}:
let
  hyprCfg = config.my.hyprland;
  cfg = config.my.hyprland.clipboard;
  yaziEnabled = config.my.yazi.enable;
in
{
  options.my.hyprland.clipboard = {
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
