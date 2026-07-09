{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.modules.bat;
in
{
  options.modules.bat.enable = lib.mkEnableOption "";

  config = lib.mkIf cfg.enable {
    programs.bat = {
      enable = true;
      config = {
        paging = "auto";
        style = "plain,header,grid";
        theme = "rose-pine-moon";
      };
      themes = {
        rose-pine-moon = {
          src = pkgs.fetchFromGitHub {
            owner = "rose-pine";
            repo = "tm-theme";
            rev = "417d201beb5f0964faded5448147c252ff12c4ae";
            sha256 = "sha256-aNDOqY81FLFQ6bvsTiYgPyS5lJrqZnFMpvpTCSNyY0Y=";
          };
          file = "dist/rose-pine-moon.tmTheme";
        };
      };
    };
  };
}
