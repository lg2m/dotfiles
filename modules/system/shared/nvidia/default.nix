{ lib, config, ... }:
let
  cfg = config.modules.nvidia;
in
{
  options.modules.nvidia = {
    enable = lib.mkEnableOption "Enable NVIDIA proprietary driver stack.";

    enable32Bit = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Enable 32-bit graphics support (useful for some games and legacy apps).
      '';
    };

    open = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Use NVIDIA's open-source kernel module (not the Nouveau driver).
        Only supported on Turing and newer GPUs, and still considered less stable.
      '';
    };

    nvidiaSettings = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Enable the `nvidia-settings` configuration GUI.
      '';
    };

    package = lib.mkOption {
      type = lib.types.package;
      default = config.boot.kernelPackages.nvidiaPackages.stable;
      description = ''
        NVIDIA driver package to use. Defaults to the stable NVIDIA package for
        the current kernel.
      '';
    };

    addModesetKernelParam = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        If true, adds `nvidia_drm.modeset=1` to boot.kernelParams to enable DRM
        modesetting, which is required for some compositors and smooth graphics.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    boot.kernelParams = lib.optionals cfg.addModesetKernelParam [ "nvidia_drm.modeset=1" ];

    hardware = {
      graphics = {
        enable = true;
        enable32Bit = cfg.enable32Bit;
      };
      nvidia = {
        modesetting.enable = true;
        nvidiaSettings = cfg.nvidiaSettings;
        open = cfg.open;
        package = cfg.package;
      };
    };

    services.xserver.videoDrivers = [ "nvidia" ];

    # Enable Docker NVIDIA runtime
    hardware.nvidia-container-toolkit.enable = true;
  };
}
