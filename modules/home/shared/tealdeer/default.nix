{ lib, config, ... }:
let
  cfg = config.modules.tealdeer;
in
{
  options.modules.tealdeer.enable = lib.mkEnableOption "";

  config = lib.mkIf cfg.enable {
    programs.tealdeer = {
      enable = true;
      enableAutoUpdates = true;
    };
  };
}
