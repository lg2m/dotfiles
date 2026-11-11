{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.my.hyprland;
  toLua = lib.generators.toLua { multiline = false; };
  inline = lib.generators.mkLuaInline;

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

  bindType = lib.types.submodule {
    options = {
      keys = lib.mkOption {
        type = lib.types.str;
        example = "SUPER + SHIFT + Q";
        description = "Key combo in Hyprland Lua syntax (`MOD + MOD + key`).";
      };
      exec = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Shell command to run (`hl.dsp.exec_cmd`).";
      };
      execRules = lib.mkOption {
        type = lib.types.attrsOf (
          lib.types.oneOf [
            lib.types.str
            lib.types.int
            lib.types.bool
          ]
        );
        default = { };
        example = {
          workspace = "5 silent";
        };
        description = "Window rule effects applied to the window spawned by `exec`.";
      };
      dispatcher = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        example = "hl.dsp.window.close()";
        description = "Raw Lua dispatcher expression. Mutually exclusive with `exec`.";
      };
      flags = lib.mkOption {
        type = lib.types.attrsOf lib.types.bool;
        default = { };
        example = {
          repeating = true;
        };
        description = "Bind flags (`hl.bind` options table).";
      };
    };
  };

  luaTable = lib.types.attrsOf lib.types.anything;

  inherit (cfg) mod;

  renderAction =
    b:
    if b.exec != null then
      inline "hl.dsp.exec_cmd(${toLua b.exec}${
        lib.optionalString (b.execRules != { }) ", ${toLua b.execRules}"
      })"
    else
      inline b.dispatcher;

  renderBind = b: {
    _args = [
      b.keys
      (renderAction b)
    ]
    ++ lib.optional (b.flags != { }) b.flags;
  };

  startupHook = inline (
    "function()\n" + lib.concatMapStrings (c: "  hl.exec_cmd(${toLua c})\n") cfg.startup + "end"
  );

  workspaceBinds = lib.concatLists (
    lib.genList (
      i:
      let
        ws = i + 1;
        key = if ws == 10 then "0" else toString ws;
      in
      [
        {
          keys = "${mod} + ${key}";
          dispatcher = "hl.dsp.focus({ workspace = ${toString ws} })";
        }
        {
          keys = "${mod} + SHIFT + ${key}";
          dispatcher = "hl.dsp.window.move({ workspace = ${toString ws}, follow = true })";
        }
      ]
    ) 10
  );

  directions = {
    H = "left";
    J = "down";
    K = "up";
    L = "right";
  };

  directionBinds = lib.concatLists (
    lib.mapAttrsToList (key: dir: [
      {
        keys = "${mod} + ${key}";
        dispatcher = ''hl.dsp.focus({ direction = "${dir}" })'';
      }
      {
        keys = "${mod} + SHIFT + ${key}";
        dispatcher = ''hl.dsp.window.move({ direction = "${dir}" })'';
      }
    ]) directions
  );

  coreBinds = [
    {
      keys = "${mod} + RETURN";
      exec = cfg.apps.terminal;
      execRules.workspace = "5 silent";
    }
    {
      keys = "${mod} + B";
      exec = cfg.apps.browser;
      execRules.workspace = "1 silent";
    }
    {
      keys = "${mod} + S";
      exec = cfg.apps.spotify;
      execRules.workspace = "3 silent";
    }
    {
      keys = "${mod} + D";
      exec = cfg.apps.discord;
      execRules.workspace = "4 silent";
    }
    {
      keys = "${mod} + T";
      exec = cfg.apps.teams;
      execRules.workspace = "2 silent";
    }
    {
      keys = "${mod} + SHIFT + E";
      dispatcher = "hl.dsp.exit()";
    }
    {
      keys = "${mod} + CTRL + R";
      exec = "hyprctl reload";
    }
    {
      keys = "${mod} + SHIFT + Q";
      dispatcher = "hl.dsp.window.close()";
    }
    {
      keys = "${mod} + F";
      dispatcher = ''hl.dsp.window.fullscreen({ mode = "fullscreen" })'';
    }
    {
      keys = "${mod} + SHIFT + SPACE";
      dispatcher = "hl.dsp.window.float()";
    }
    {
      keys = "${mod} + bracketright";
      dispatcher = ''hl.dsp.focus({ workspace = "e+1" })'';
    }
    {
      keys = "${mod} + bracketleft";
      dispatcher = ''hl.dsp.focus({ workspace = "e-1" })'';
    }
    {
      keys = "${mod} + mouse_down";
      dispatcher = ''hl.dsp.focus({ workspace = "e+1" })'';
    }
    {
      keys = "${mod} + mouse_up";
      dispatcher = ''hl.dsp.focus({ workspace = "e-1" })'';
    }
  ]
  ++ directionBinds;
in
{
  options.my.hyprland = {
    enable = lib.mkEnableOption "Enable shared Hyprland user session config.";

    mod = lib.mkOption {
      type = lib.types.str;
      default = "SUPER";
      description = "Main modifier used by the shared keybindings.";
    };

    apps = lib.mkOption {
      type = appOptions;
      default = { };
      description = "Application commands used by the shared Hyprland session.";
    };

    startup = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Commands run once when Hyprland starts (`hyprland.start` event).";
    };

    binds = lib.mkOption {
      type = lib.types.listOf bindType;
      default = [ ];
      description = "Keybindings. Components and hosts append to this list.";
    };

    monitors = lib.mkOption {
      type = lib.types.listOf luaTable;
      default = [ ];
      example = [
        {
          output = "";
          mode = "preferred";
          position = "auto";
          scale = 1;
        }
      ];
      description = "`hl.monitor` specs.";
    };

    windowRules = lib.mkOption {
      type = lib.types.listOf luaTable;
      default = [ ];
      example = [
        {
          match.class = "^(pavucontrol)$";
          float = true;
        }
      ];
      description = "`hl.window_rule` specs.";
    };

    workspaceRules = lib.mkOption {
      type = lib.types.listOf luaTable;
      default = [ ];
      description = "`hl.workspace_rule` specs.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = pkgs.stdenv.hostPlatform.isLinux;
        message = "my.hyprland currently targets Linux/Home Manager environments only.";
      }
    ]
    ++ map (b: {
      assertion = (b.exec == null) != (b.dispatcher == null);
      message = "my.hyprland.binds: '${b.keys}' must set exactly one of `exec` or `dispatcher`.";
    }) cfg.binds;

    my.hyprland.binds = coreBinds ++ workspaceBinds;

    xdg.configFile."hypr/hyprland.lua".force = lib.mkForce true;

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
      enable = true;
      gtk.enable = true;
      x11.enable = true;
      package = pkgs.adwaita-icon-theme;
      name = "Adwaita";
      size = 24;
    };

    # Hyprland >= 0.57 only reads hyprland.lua (hyprlang support was removed).
    wayland.windowManager.hyprland = {
      enable = true;
      configType = "lua";
      systemd.enable = true;
      settings = {
        bind = map renderBind cfg.binds;
      }
      // lib.optionalAttrs (cfg.startup != [ ]) {
        on = [
          {
            _args = [
              "hyprland.start"
              startupHook
            ];
          }
        ];
      }
      // lib.optionalAttrs (cfg.monitors != [ ]) {
        monitor = cfg.monitors;
      }
      // lib.optionalAttrs (cfg.windowRules != [ ]) {
        window_rule = cfg.windowRules;
      }
      // lib.optionalAttrs (cfg.workspaceRules != [ ]) {
        workspace_rule = cfg.workspaceRules;
      };
    };
  };
}
