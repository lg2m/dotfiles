{ lib, config, ... }:
let
  cfg = config.modules.eza;
in
{
  options.modules.eza.enable = lib.mkEnableOption "";

  config = lib.mkIf cfg.enable {
    programs.eza = {
      enable = true;
      enableZshIntegration = true;
      extraOptions = [ "--group-directories-first" ];
      git = true;
      icons = "auto";
    };
  };
}
