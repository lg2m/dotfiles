{
  lib,
  config,
  pkgs,
  ...
}:
let
  hyprCfg = config.modules.hyprland;
  cfg = config.modules.hyprland.awww;
  wallpapersDir = ../../../../../wallpapers;
  cycleScript = pkgs.writeShellScriptBin "awww-wallpaper-cycle" ''
    wallpapers_dir="${config.xdg.configHome}/hypr/wallpapers"

    wait_for_daemon() {
      for _ in $(${pkgs.coreutils}/bin/seq 1 100); do
        if ${pkgs.awww}/bin/awww query >/dev/null 2>&1; then
          return 0
        fi
        ${pkgs.coreutils}/bin/sleep 0.1
      done

      return 1
    }

    pick_random_wallpaper() {
      ${pkgs.findutils}/bin/find -L "$wallpapers_dir" -type f \
        \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) \
        | ${pkgs.coreutils}/bin/shuf -n 1
    }

    set_random_wallpaper() {
      wallpaper="$(pick_random_wallpaper)"

      if [ -z "$wallpaper" ]; then
        return 0
      fi

      ${pkgs.awww}/bin/awww img "$wallpaper" --transition-type ${cfg.transitionType} --transition-duration ${toString cfg.transitionDuration}
    }

    if ! wait_for_daemon; then
      exit 0
    fi

    set_random_wallpaper

    while true; do
      ${pkgs.coreutils}/bin/sleep ${toString cfg.intervalSeconds}
      set_random_wallpaper
    done
  '';
in
{
  options.modules.hyprland.awww = {
    enable = (lib.mkEnableOption "Enable awww wallpaper management for Hyprland sessions.") // {
      default = true;
    };

    intervalSeconds = lib.mkOption {
      type = lib.types.int;
      default = 900;
      description = "Seconds between automatic wallpaper changes.";
    };

    transitionType = lib.mkOption {
      type = lib.types.str;
      default = "none";
      description = "Transition type used for wallpaper changes.";
    };

    transitionDuration = lib.mkOption {
      type = lib.types.float;
      default = 0.0;
      description = "Transition duration in seconds for wallpaper changes.";
    };
  };

  config = lib.mkIf (hyprCfg.enable && cfg.enable) {
    home.packages = [
      pkgs.awww
      cycleScript
    ];

    xdg.configFile."hypr/wallpapers".source = wallpapersDir;

    wayland.windowManager.hyprland.settings = {
      "exec-once" = [
        "${pkgs.awww}/bin/awww-daemon --no-cache"
        "${cycleScript}/bin/awww-wallpaper-cycle"
      ];
    };
  };
}
