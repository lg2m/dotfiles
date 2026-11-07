{
  lib,
  config,
  pkgs,
  ...
}:
let
  hyprCfg = config.my.hyprland;
  cfg = config.my.hyprland.screenshot;
in
{
  options.my.hyprland.screenshot = {
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

    my.hyprland.binds = [
      {
        keys = "${hyprCfg.mod} + SHIFT + S";
        exec = "hyprshot -m region";
      }
      {
        keys = "${hyprCfg.mod} + CTRL + S";
        exec = "hyprshot -m window";
      }
      {
        keys = "${hyprCfg.mod} + ALT + S";
        exec = "hyprshot -m output";
      }
    ];
  };
}
