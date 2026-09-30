{ lib, config, ... }:
{
  config = lib.mkIf config.modules.hyprland.enable {
    services = {
      displayManager = {
        sddm = {
          enable = true;
          wayland.enable = true;
        };
        defaultSession = "hyprland";
        autoLogin = {
          enable = true;
          user = "zmeyer";
        };
      };

      xserver = {
        enable = true;
      };
    };
  };
}
