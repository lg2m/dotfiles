{ lib, config, ... }:
let
  cfg = config.modules.dbus;
in
{
  options.modules.dbus = {
    enable = lib.mkEnableOption "Enable the D-Bus message bus daemon.";

    implementation = lib.mkOption {
      type = lib.types.enum [
        "broker"
        "dbus-daemon"
      ];
      default = "broker";
      example = "broker";
      description = ''
        D-Bus implementation to use.
        "broker" is the modern high-performance implementation.
        "dbus-daemon" is the classic reference implementation.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    services.dbus = {
      enable = true;
      implementation = cfg.implementation;
    };
  };
}
