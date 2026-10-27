{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.my.ai.herdr;
  opencodeAssets = "${inputs.herdr}/src/integration/assets/opencode";
in
{
  options.my.ai.herdr = {
    enable = lib.mkEnableOption "Herdr terminal workspace manager for AI coding agents";
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      { home.packages = [ pkgs.herdr ]; }

      # Declarative `herdr integration install opencode`: the installer cannot
      # edit the Home Manager-owned cli.json, so ship its OpenCode 2 assets here.
      (lib.mkIf config.programs.opencode.enable {
        xdg.configFile = {
          # Replaces the V1 copy written by older herdr installers.
          "opencode/plugins/herdr-agent-state.js" = {
            source = "${opencodeAssets}/herdr-agent-state.js";
            force = true;
          };
          # Upstream's tui.js imports a sibling by relative path, which breaks
          # once the file resolves into the store; import it absolutely instead.
          "opencode/herdr-opencode/tui.js".text = ''
            export { default } from "${opencodeAssets}/herdr-tui-session.js";
          '';
        };
        programs.opencode.cli.plugins = [ "${config.xdg.configHome}/opencode/herdr-opencode" ];
      })
    ]
  );
}
