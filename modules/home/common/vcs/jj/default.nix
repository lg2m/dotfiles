{ lib, config, ... }:
let
  cfg = config.my.vcs.jj;
  id = config.my.identity;
in
{
  options.my.vcs.jj.enable = lib.mkEnableOption "Jujutsu version control configuration";

  config = lib.mkIf cfg.enable {
    programs.jujutsu = {
      enable = true;
      settings.user = {
        inherit (id) email;
        name = id.fullName;
      };
    };
  };
}
