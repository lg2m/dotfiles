{ lib, config, ... }:
let
  cfg = config.my.tealdeer;
in
{
  options.my.tealdeer.enable = lib.mkEnableOption "";

  config = lib.mkIf cfg.enable {
    programs.tealdeer = {
      enable = true;
      enableAutoUpdates = true;
    };
  };
}
