{ lib, config, ... }:
{
  config = lib.mkIf config.my.hyprland.enable {
    my.hyprland = {
      monitors = [
        ",preferred,auto,1"
      ];
    };
  };
}
