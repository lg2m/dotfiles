{
  lib,
  config,
  pkgs,
  ...
}:
let
  hyprCfg = config.modules.hyprland;
  cfg = config.modules.hyprland.thunar;
  thunarExe = lib.getExe pkgs.thunar;
in
{
  options.modules.hyprland.thunar = {
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
