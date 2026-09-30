{ lib, config, ... }:
{
  config = lib.mkIf config.my.hyprland.enable {
    my.hyprland = {
      monitors = [
        ",5120x1440@239.76,auto,1"
      ];

      startup = [
        "goxlr-daemon"
      ];
    };
  };
}
