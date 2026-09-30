{ lib, config, ... }:
let
  cfg = config.modules.ghostty;

  # Single source of truth for ghostty settings.
  settings = {
    background = "#000000";
    background-blur = false;
    background-opacity = 0.85;
    cursor-style = "bar";
    font-family = "Noto";
    keybind = [
      "ctrl+enter=unbind"
      "alt+backspace=text:\\x1b\\x7f"
    ];
    mouse-hide-while-typing = true;
    shell-integration-features = "no-sudo,ssh-env,ssh-terminfo";
    theme = "Rose Pine Moon";
    window-theme = "dark";
  };

  # Render a single key/value pair into ghostty's `key = value` config syntax.
  # Lists become repeated lines for the same key.
  renderEntry =
    key: value:
    let
      render =
        v:
        if builtins.isBool v then
          (if v then "true" else "false")
        else if builtins.isFloat v then
          # Trim trailing zeros so 0.85 stays "0.85" rather than "0.850000".
          (
            let
              m = builtins.match "(-?[0-9]+\\.[0-9]*[1-9]|-?[0-9]+)0*\\.?0*" (toString v);
            in
            if m == null then toString v else builtins.head m
          )
        else
          toString v;
    in
    if builtins.isList value then
      lib.concatMapStringsSep "\n" (v: "${key} = ${render v}") value
    else
      "${key} = ${render value}";

  renderedConfig = lib.concatStringsSep "\n" (lib.mapAttrsToList renderEntry settings) + "\n";
in
{
  options.modules.ghostty = {
    enable = lib.mkEnableOption "Enable ghostty terminal configuration.";

    installPackage = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Install ghostty via home-manager's `programs.ghostty`.

        Set to false on machines where ghostty is provided externally
        (e.g. corp-managed hosts) so only the config file is managed.
      '';
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      # Adapter: install + manage config via the home-manager program module.
      (lib.mkIf cfg.installPackage {
        programs.ghostty = {
          enable = true;
          enableZshIntegration = true;
          inherit settings;
        };
      })
      # Adapter: config-only, writing the same settings to the raw config file.
      (lib.mkIf (!cfg.installPackage) {
        xdg.configFile."ghostty/config".text = renderedConfig;
      })
    ]
  );
}
