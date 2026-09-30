{ lib, config, ... }:
{
  config = lib.mkIf config.modules.hyprland.enable {
    modules.hyprland = {
      monitors = [
        ",5120x1440@239.76,auto,1"
      ];

      startup = [
        "goxlr-daemon"
      ];
    };
  };
}
