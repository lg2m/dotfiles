{ lib, config, ... }:
let
  cfg = config.modules.fontconfig;
in
{
  options.modules.fontconfig = {
    enable = lib.mkEnableOption "Enable and configure Fontconfig for system fonts.";

    antialias = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable font antialiasing.";
    };

    hintingEnable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable font hinting.";
    };

    hintingStyle = lib.mkOption {
      type = lib.types.enum [
        "none"
        "slight"
        "medium"
        "full"
      ];
      default = "slight";
      description = "Font hinting style.";
    };

    subpixelRgba = lib.mkOption {
      type = lib.types.enum [
        "none"
        "rgb"
        "bgr"
        "vrgb"
        "vbgr"
      ];
      default = "rgb";
      description = "Subpixel RGB ordering for LCD screens.";
    };

    subpixelLcdfilter = lib.mkOption {
      type = lib.types.enum [
        "none"
        "default"
        "light"
        "legacy"
      ];
      default = "default";
      description = "LCD filter used for subpixel rendering.";
    };
  };

  config = lib.mkIf cfg.enable {
    fonts.fontconfig = {
      enable = true;
      antialias = cfg.antialias;
      subpixel = {
        rgba = cfg.subpixelRgba;
        lcdfilter = cfg.subpixelLcdfilter;
      };
      hinting = {
        enable = cfg.hintingEnable;
        style = cfg.hintingStyle;
      };
    };
  };
}
