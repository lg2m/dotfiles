{ lib, config, ... }:
let
  cfg = config.modules.bluetooth;
in
{
  options.modules.bluetooth = {
    enable = lib.mkEnableOption "Enable Bluetooth support and Blueman applet.";

    powerOnBoot = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Automatically power on Bluetooth adapters at boot.";
    };

    enableBlueman = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable the Blueman Bluetooth management UI.";
    };
  };

  config = lib.mkIf cfg.enable {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = cfg.powerOnBoot;
    };

    services.blueman.enable = cfg.enableBlueman;
  };
}
