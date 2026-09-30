{ lib, config, ... }:
let
  cfg = config.my.zoxide;
in
{
  options.my.zoxide.enable = lib.mkEnableOption "";

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
