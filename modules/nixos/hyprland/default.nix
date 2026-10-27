{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.my.hyprland;
in
{
  options.my.hyprland = {
    enable = lib.mkEnableOption "Enable shared Hyprland system foundations.";
  };

  config = lib.mkIf cfg.enable {
    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
    };

    xdg.portal = {
      enable = true;
      xdgOpenUsePortal = true;
      # programs.hyprland already adds its matching portalPackage; adding
      # pkgs.xdg-desktop-portal-hyprland too collides in user-units.
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
      config = {
        common.default = [
          "hyprland"
          "gtk"
        ];
        hyprland.default = [
          "hyprland"
          "gtk"
        ];
      };
    };

    environment.systemPackages = with pkgs; [
      xdg-utils
    ];
  };
}
