{ lib, config, ... }:
let
  cfg = config.modules.direnv;
in
{
  options.modules.direnv.enable = lib.mkEnableOption "";

  config = lib.mkIf cfg.enable {
    programs.direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
      config = {
        global = {
          disable_stdin = true;
          warn_timeout = 0;
          hide_env_diff = true;
        };
      };
    };
  };
}
