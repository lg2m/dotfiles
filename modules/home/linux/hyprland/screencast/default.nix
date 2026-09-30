{
  lib,
  config,
  pkgs,
  ...
}:
let
  hyprCfg = config.modules.hyprland;
  cfg = config.modules.hyprland.screencast;

  recordDir = "${config.home.homeDirectory}/Videos/Recordings";

  # Toggle-style recorder built on wf-recorder + slurp.
  #
  # Usage:
  #   screencast region   -> select a region with slurp, then record it
  #   screencast output    -> record the focused monitor
  #
  # Running the script again while a recording is active stops it
  # (SIGINT lets wf-recorder finalize the file cleanly).
  screencast = pkgs.writeShellApplication {
    name = "screencast";
    runtimeInputs = [
      pkgs.wf-recorder
      pkgs.slurp
      pkgs.hyprland # provides hyprctl
      pkgs.libnotify
      pkgs.coreutils
      pkgs.procps # pkill/pgrep
      pkgs.jq
    ];
    text = ''
      mode="''${1:-region}"
      dir="${recordDir}"
      mkdir -p "$dir"

      # If a recording is already running, stop it and exit.
      if pgrep -x wf-recorder >/dev/null 2>&1; then
        pkill -INT -x wf-recorder
        notify-send -a screencast "Screencast" "Recording stopped"
        exit 0
      fi

      file="$dir/$(date +%Y-%m-%d_%H-%M-%S).mp4"

      # Audio: capture the default PipeWire source (works with GoXLR
      # routing via pavucontrol). "--audio" alone uses the default source.
      audio_args=(--audio)

      case "$mode" in
        region)
          geom="$(slurp)" || exit 1
          notify-send -a screencast "Screencast" "Recording region… run again to stop"
          wf-recorder "''${audio_args[@]}" -g "$geom" -f "$file"
          ;;
        output)
          # Record the monitor of the currently focused window.
          out="$(hyprctl activeworkspace -j | jq -r '.monitor')"
          notify-send -a screencast "Screencast" "Recording $out… run again to stop"
          wf-recorder "''${audio_args[@]}" -o "$out" -f "$file"
          ;;
        *)
          notify-send -a screencast "Screencast" "Unknown mode: $mode"
          exit 1
          ;;
      esac

      notify-send -a screencast "Screencast" "Saved $file"
    '';
  };
in
{
  options.modules.hyprland.screencast = {
    enable = (lib.mkEnableOption "Enable screen recording tooling for Hyprland sessions.") // {
      default = true;
    };
  };

  config = lib.mkIf (hyprCfg.enable && cfg.enable) {
    home.packages = [
      screencast
      pkgs.wf-recorder
      pkgs.slurp
      pkgs.libnotify
    ];

    wayland.windowManager.hyprland.settings = {
      bind = [
        "$mod SHIFT, R, exec, screencast region"
        "$mod ALT, R, exec, screencast output"
      ];
    };
  };
}
