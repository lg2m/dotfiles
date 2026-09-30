{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.my.hyprland.eww;
in
{
  options.my.hyprland.eww = {
    enable = lib.mkEnableOption "Enable Eww bar for Hyprland sessions.";
  };

  config = lib.mkIf (config.my.hyprland.enable && cfg.enable) {
    home.packages = [
      pkgs.eww
      pkgs.playerctl
      pkgs.jq
      pkgs.git
    ];

    xdg.configFile."eww/eww.yuck".source = ./eww.yuck;

    xdg.configFile."eww/eww.scss".source = ./eww.scss;

    wayland.windowManager.hyprland.settings = {
      "exec-once" = [
        "bash -lc 'eww daemon; sleep 0.2; eww open bar-main'"
      ];
    };
  };
}
