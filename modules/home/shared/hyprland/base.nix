{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.modules.hyprland;
  appOptions = lib.types.submodule {
    options = {
      terminal = lib.mkOption {
        type = lib.types.str;
        default = "ghostty";
        description = "Terminal command used by Hyprland keybindings.";
      };

      browser = lib.mkOption {
        type = lib.types.str;
        default = "xdg-open";
        description = "Browser command used by Hyprland keybindings.";
      };

      spotify = lib.mkOption {
        type = lib.types.str;
        default = "spotify";
        description = "Spotify command used by Hyprland keybindings.";
      };

      discord = lib.mkOption {
        type = lib.types.str;
        default = "discord";
        description = "Discord command used by Hyprland keybindings.";
      };

      teams = lib.mkOption {
        type = lib.types.str;
        default = "teams-for-linux";
        description = "Teams command used by Hyprland keybindings.";
      };
    };
  };
  workspaceBinds = lib.concatLists (
    lib.genList (
      i:
      let
        ws = i + 1;
        key = if ws == 10 then "0" else toString ws;
      in
      [
        "$mod, ${key}, workspace, ${toString ws}"
        "$mod SHIFT, ${key}, movetoworkspace, ${toString ws}"
      ]
    ) 10
  );
in
{
  options.modules.hyprland = {
    enable = lib.mkEnableOption "Enable shared Hyprland user session config.";

    apps = lib.mkOption {
      type = appOptions;
      default = { };
      description = "Application commands used by the shared Hyprland session.";
    };

    startup = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Session startup commands appended to exec-once.";
    };

    extraBinds = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Additional Hyprland binds appended to shared keybindings.";
    };

    monitors = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Monitor definitions appended to Hyprland settings.";
    };

    workspaceRules = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Workspace rules appended to Hyprland settings.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = pkgs.stdenv.isLinux;
        message = "modules.hyprland currently targets Linux/Home Manager environments only.";
      }
    ];

    xdg.configFile."hypr/hyprland.conf".force = lib.mkForce true;

    home.sessionVariables = {
      HYPRCURSOR_THEME = "Adwaita";
      HYPRCURSOR_SIZE = "24";
      ELECTRON_OZONE_PLATFORM_HINT = "auto";
      MOZ_ENABLE_WAYLAND = "1";
      NIXOS_OZONE_WL = "1";
      QT_QPA_PLATFORM = "wayland;xcb";
      SDL_VIDEODRIVER = "wayland,x11";
      XCURSOR_THEME = "Adwaita";
      XCURSOR_SIZE = "24";
    };

    home.pointerCursor = {
      gtk.enable = true;
      x11.enable = true;
      package = pkgs.adwaita-icon-theme;
      name = "Adwaita";
      size = 24;
    };

    wayland.windowManager.hyprland = {
      enable = true;
      configType = "hyprlang";
      systemd.enable = true;
      settings = {
        "$mod" = "SUPER";
        "$terminal" = cfg.apps.terminal;
        "$browser" = cfg.apps.browser;
        "$spotify" = cfg.apps.spotify;
        "$discord" = cfg.apps.discord;
        "$teams" = cfg.apps.teams;
        bind = [
          "$mod, RETURN, exec, [workspace 5 silent] $terminal"
          "$mod, B, exec, [workspace 1 silent] $browser"
          "$mod, S, exec, [workspace 3 silent] $spotify"
          "$mod, D, exec, [workspace 4 silent] $discord"
          "$mod, T, exec, [workspace 2 silent] $teams"
          "$mod SHIFT, E, exit"
          "$mod SHIFT, R, exec, hyprctl reload"
          "$mod SHIFT, Q, killactive"
          "$mod, F, fullscreen, 0"
          "$mod SHIFT, SPACE, togglefloating"
          "$mod, H, movefocus, l"
          "$mod, J, movefocus, d"
          "$mod, K, movefocus, u"
          "$mod, L, movefocus, r"
          "$mod SHIFT, H, movewindow, l"
          "$mod SHIFT, J, movewindow, d"
          "$mod SHIFT, K, movewindow, u"
          "$mod SHIFT, L, movewindow, r"
          "$mod, bracketright, workspace, e+1"
          "$mod, bracketleft, workspace, e-1"
          "$mod, mouse_down, workspace, e+1"
          "$mod, mouse_up, workspace, e-1"
        ]
        ++ cfg.extraBinds
        ++ workspaceBinds;
      }
      // lib.optionalAttrs (cfg.startup != [ ]) {
        "exec-once" = cfg.startup;
      }
      // lib.optionalAttrs (cfg.monitors != [ ]) {
        monitor = cfg.monitors;
      }
      // lib.optionalAttrs (cfg.workspaceRules != [ ]) {
        workspace = cfg.workspaceRules;
      };
    };
  };
}
