{
  lib,
  config,
  pkgs,
  ...
}:
let
  hyprCfg = config.my.hyprland;
  cfg = config.my.hyprland.eww;

  script =
    name: runtimeInputs:
    pkgs.writeShellApplication {
      name = "eww-${name}";
      inherit runtimeInputs;
      # Long-running listeners: keep going when one command fails.
      bashOptions = [ ];
      text = builtins.readFile ./scripts/eww-${name}.sh;
    };

  scripts = {
    hypr = script "hypr" [
      config.wayland.windowManager.hyprland.finalPackage
      pkgs.socat
      pkgs.jq
      pkgs.git
      pkgs.procps
      pkgs.coreutils
    ];
    volume = script "volume" [
      pkgs.wireplumber
      pkgs.pulseaudio # pactl subscribe
      pkgs.gawk
    ];
    media = script "media" [
      pkgs.playerctl
      pkgs.jq
    ];
    stats = script "stats" [
      pkgs.gawk
      pkgs.iproute2
      pkgs.procps
      pkgs.mako
      pkgs.gnugrep
      pkgs.coreutils
    ];
    battery = script "battery" [ ];
    toggle = script "toggle" [
      cfg.package
      pkgs.gnugrep
    ];
    open = script "open" [
      cfg.package
      pkgs.coreutils
    ];
  };

  substituted = removeAttrs scripts [ "open" ];
  yuck = pkgs.writeText "eww.yuck" (
    builtins.replaceStrings (map (n: "@${n}@") (lib.attrNames substituted)) (map lib.getExe (
      lib.attrValues substituted
    )) (builtins.readFile ./eww.yuck)
  );

  ewwCmd = lib.getExe cfg.package;
in
{
  options.my.hyprland.eww = {
    enable = lib.mkEnableOption "Enable Eww bar for Hyprland sessions.";

    package = lib.mkPackageOption pkgs "eww" { };
  };

  config = lib.mkIf (hyprCfg.enable && cfg.enable) {
    home.packages = [
      cfg.package
      pkgs.playerctl
      pkgs.pavucontrol
    ];

    xdg.configFile = {
      "eww/eww.yuck".source = yuck;
      "eww/eww.scss".source = ./eww.scss;
    };

    # Run as a user service so it starts with the session, restarts on crash,
    # and restarts automatically on `home-manager switch` when the config changes.
    #
    #   systemctl --user restart eww     # full restart
    #   eww reload                       # reload config in place
    #   Super+Shift+B                    # restart (keybind below)
    systemd.user.services.eww = {
      Unit = {
        Description = "Eww bar";
        Documentation = "https://elkowar.github.io/eww/";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
        Requisite = [ "graphical-session.target" ];
        X-Restart-Triggers = [
          "${yuck}"
          "${./eww.scss}"
        ];
      };
      Service = {
        ExecStart = "${ewwCmd} daemon --no-daemonize";
        ExecStartPost = lib.getExe scripts.open;
        ExecReload = "${ewwCmd} reload";
        ExecStop = "${ewwCmd} kill";
        Restart = "on-failure";
        RestartSec = 2;
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };

    wayland.windowManager.hyprland.settings = {
      bind = [
        "$mod SHIFT, B, exec, systemctl --user restart eww"
        "$mod, N, exec, makoctl mode -t do-not-disturb"
      ];
    };
  };
}
