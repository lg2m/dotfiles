{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.modules.pipewire;
in
{
  options.modules.pipewire = {
    enable = lib.mkEnableOption "Enable Pipewire Audio & Video service.";

    goxlr = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Enable the unofficial GoXLR App replacement for Linux.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      pulseaudio
      pavucontrol
      pamixer
    ];

    security.rtkit.enable = true;

    services = {
      goxlr-utility.enable = cfg.goxlr;
      pipewire = {
        alsa.enable = true;
        alsa.support32Bit = true;
        enable = true;
        jack.enable = true;
        pulse.enable = true;
      };
    };
  };
}
