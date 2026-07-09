{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.modules.gamemode;
in
{
  options.modules.gamemode = {
    enable = lib.mkEnableOption "";
  };

  config = lib.mkIf cfg.enable {
    programs.gamemode = {
      enable = true;
      enableRenice = true;
      settings = {
        general = {
          desiredgov = "performance";
          defaultgov = "performance";
          renice = 10; # -> nice = -10 (higher CPU prio for game)
          ioprio = 0; # keep disk prio default (0);
          inhibit_screensaver = 1;
          softrealtime = "auto"; # try SCHED_ISO-like boost when possible
        };
        cpu = {
          park_cores = "yes"; # keep cores unparked to avoid wake latency spikes
        };
        gpu = {
          apply_gpu_optimisations = "accept-responsibility";
          # NIVIDIA: Prefer maximum performance.
          # 0=Adaptive, 1=Prefer Maximum Performance, 2=Auto (driver-dependent)
          nv_powermizer_mode = 1;
          # Apply an overclock to the GPU.
          #nv_core_clock_mhz_offset = 150;
          #nv_mem_clock_mhz_offset = 1000;
        };
        custom = {
          start = "${pkgs.libnotify}/bin/notify-send 'GameMode' 'Activated'";
          end = "${pkgs.libnotify}/bin/notify-send 'GameMode' 'Deactivated'";
        };
      };
    };

    # Ensure user is in gamemode group for proper permissions.
    users.users.zmeyer.extraGroups = [ "gamemode" ];
  };
}
