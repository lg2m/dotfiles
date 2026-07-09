{ lib, config, ... }:
let
  cfg = config.modules.systemd-boot;
in
{
  options.modules.systemd-boot = {
    enable = lib.mkEnableOption "Enable systemd-boot as the system bootloader.";

    efiCanTouchVariables = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Whether NixOS is allowed to modify EFI variables (like the boot order)
        when configuring systemd-boot. On some systems/firmware this is better
        left disabled.
      '';
    };

    timeout = lib.mkOption {
      type = lib.types.ints.unsigned;
      default = 0;
      description = ''
        Timeout in seconds for the systemd-boot menu.
        0 means no menu unless you press a key (e.g. ESC) at boot.
      '';
    };

    issueText = lib.mkOption {
      type = lib.types.str;
      default = "[?12l[?25h";
      description = ''
        Contents of /etc/issue shown on TTY login. The default value disables
        the blinking cursor escape sequence commonly used on some setups.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    boot.loader = {
      efi.canTouchEfiVariables = cfg.efiCanTouchVariables;
      systemd-boot.enable = true;
      timeout = cfg.timeout;
    };

    environment.etc."issue" = {
      text = cfg.issueText;
      mode = "0444";
    };
  };
}
