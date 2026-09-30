{ lib, config, ... }:
let
  cfg = config.my.sudo-rs;
in
{
  options.my.sudo-rs = {
    enable = lib.mkEnableOption "Use sudo-rs instead of traditional sudo.";

    wheelNeedsPassword = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        If true, members of the wheel group must enter their password when using sudo-rs.
        If false, wheel can sudo without a password (not recommended for most setups).
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    security.sudo.enable = false;

    security.sudo-rs = {
      enable = true;
      inherit (cfg) wheelNeedsPassword;
    };
  };
}
