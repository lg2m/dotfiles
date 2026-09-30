{ lib, config, ... }:
let
  cfg = config.modules.vcs.jj;
in
{
  options.modules.vcs.jj.enable = lib.mkEnableOption "Jujutsu version control configuration";

  config = lib.mkIf cfg.enable {
    programs.jujutsu = {
      enable = true;
      settings = {
        user = {
          email = "159225316+lg2m@users.noreply.github.com";
          name = "Zachary Meyer";
        };
      };
    };
  };
}
