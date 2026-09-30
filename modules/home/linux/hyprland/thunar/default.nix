{
  lib,
  config,
  pkgs,
  ...
}:
let
  hyprCfg = config.my.hyprland;
  cfg = config.my.hyprland.thunar;
  thunarExe = lib.getExe pkgs.thunar;
in
{
  options.my.hyprland.thunar = {
    enable = (lib.mkEnableOption "Enable the Thunar file manager for Hyprland sessions.") // {
      default = true;
    };
  };

  config = lib.mkIf (hyprCfg.enable && cfg.enable) {
    home.packages = with pkgs; [
      thunar
      tumbler
      gvfs
    ];

    xdg.mimeApps.defaultApplications = {
      "inode/directory" = [ "thunar.desktop" ];
    };

    wayland.windowManager.hyprland.settings = {
      bind = [
        "$mod, E, exec, ${thunarExe}"
      ];
    };
  };
}
