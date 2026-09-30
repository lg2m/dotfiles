{ lib, config, ... }:
let
  cfg = config.my.eza;
in
{
  options.my.eza.enable = lib.mkEnableOption "";

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
