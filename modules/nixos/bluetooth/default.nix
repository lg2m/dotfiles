{ lib, config, ... }:
let
  cfg = config.my.bluetooth;
in
{
  options.my.bluetooth = {
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
      inherit (cfg) powerOnBoot;
    };

    services.blueman.enable = cfg.enableBlueman;
  };
}
