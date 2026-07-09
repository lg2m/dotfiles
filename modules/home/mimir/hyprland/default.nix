{ lib, config, ... }:
{
  config = lib.mkIf config.modules.hyprland.enable {
    modules.hyprland = {
      monitors = [
        ",preferred,auto,1"
      ];
    };
  };
}
