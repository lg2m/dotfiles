{
  lib,
  config,
  pkgs,
  ...
}:
let
  hyprCfg = config.my.hyprland;
  cfg = config.my.hyprland.hypridle;
in
{
  options.my.hyprland.hypridle = {
    enable = (lib.mkEnableOption "Enable hypridle idle management for Hyprland sessions.") // {
      default = true;
    };
  };

  config = lib.mkIf (hyprCfg.enable && cfg.enable) {
    home.packages = [ pkgs.hypridle ];

    xdg.configFile."hypr/hypridle.conf".source = ./hypridle.conf;

    wayland.windowManager.hyprland.settings = {
      "exec-once" = [
        "hypridle"
      ];
    };
  };
}
