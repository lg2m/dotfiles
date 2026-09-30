{ lib, config, ... }:
let
  cfg = config.modules.zoxide;
in
{
  options.modules.zoxide.enable = lib.mkEnableOption "";

  config = lib.mkIf cfg.enable {
    programs.zoxide = {
      enable = true;
      enableZshIntegration = true;
      options = [
        "--cmd"
        "cd"
      ];
    };
  };
}
